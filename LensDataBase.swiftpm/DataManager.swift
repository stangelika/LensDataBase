import Foundation
import Combine

class DataManager: ObservableObject {
    @Published var appData: AppData?
    @Published var loadingState: DataLoadingState = .idle
    @Published var availableLenses: [Lens] = []
    @Published var cameras: [Camera] = []
    @Published var formats: [RecordingFormat] = []
    @Published var activeTab: ActiveTab = .allLenses
    @Published var selectedRentalId: String = ""

    @Published var favoriteLenses = Set<String>()
    @Published var comparisonSet = Set<String>()
    @Published var favoriteLensesList: [Lens] = []

    @Published var allLensesSelectedFormat: String = ""
    @Published var allLensesSelectedFocalCategory: FocalCategory = .all
    @Published var allLensesShowOnlyRentable: Bool = false

    @Published var groupedAndFilteredLenses: [LensGroup] = []

    private var cancellables = Set<AnyCancellable>()
    private let favoritesKey = "favoriteLenses"

    init() {
        loadFavorites()
        setupFilterPipeline()
    }

    func loadData() {
        guard loadingState == .idle else { return }

        loadingState = .loading

        let lensPublisher = NetworkService.shared.fetchLensData()
        let cameraPublisher = loadLocalJSON(from: "CAMERADATA") as AnyPublisher<CameraApiResponse, Error>

        Publishers.Zip(lensPublisher, cameraPublisher)
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.loadingState = .error(error.localizedDescription)
                }
            }, receiveValue: { [weak self] appData, cameraData in
                guard let self else { return }
                self.appData = appData
                self.cameras = cameraData.camera.sorted { $0.manufacturer < $1.manufacturer }
                self.formats = cameraData.formats
                self.collectAvailableLenses()
                self.updateFavoriteLensesList()
                self.loadingState = .loaded

                if self.selectedRentalId.isEmpty {
                    self.selectedRentalId = appData.rentals.first?.id ?? ""
                }
            })
            .store(in: &cancellables)
    }

    func refreshDataFromAPI() {
        loadingState = .loading

        NetworkService.shared.fetchLensData()
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.loadingState = .error(error.localizedDescription)
                } else {
                    self?.loadingState = .loaded
                }
            }, receiveValue: { [weak self] appData in
                guard let self else { return }
                self.appData = appData
                self.collectAvailableLenses()
                self.updateFavoriteLensesList()

                if self.selectedRentalId.isEmpty {
                    self.selectedRentalId = appData.rentals.first?.id ?? ""
                }
            })
            .store(in: &cancellables)
    }

    private func loadLocalJSON<T: Decodable>(from fileName: String) -> AnyPublisher<T, Error> {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            return Fail(error: URLError(.fileDoesNotExist)).eraseToAnyPublisher()
        }

        return Just(url)
            .tryMap { try Data(contentsOf: $0) }
            .decode(type: T.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func collectAvailableLenses() {
        availableLenses = appData?.lenses ?? []
    }

    private func saveFavorites() {
        UserDefaults.standard.set(Array(favoriteLenses), forKey: favoritesKey)
    }

    private func loadFavorites() {
        if let saved = UserDefaults.standard.array(forKey: favoritesKey) as? [String] {
            favoriteLenses = Set(saved)
            updateFavoriteLensesList()
        }
    }

    func isFavorite(lens: Lens) -> Bool {
        favoriteLenses.contains(lens.id)
    }

    func toggleFavorite(lens: Lens) {
        if isFavorite(lens: lens) {
            favoriteLenses.remove(lens.id)
        } else {
            favoriteLenses.insert(lens.id)
        }
        saveFavorites()
        updateFavoriteLensesList()
    }

    private func updateFavoriteLensesList() {
        favoriteLensesList = availableLenses
            .filter { favoriteLenses.contains($0.id) }
            .sorted { $0.display_name < $1.display_name }
    }

    func isInComparison(lens: Lens) -> Bool {
        comparisonSet.contains(lens.id)
    }

    func toggleComparison(lens: Lens) {
        if isInComparison(lens: lens) {
            comparisonSet.remove(lens.id)
        } else if comparisonSet.count < 4 {
            comparisonSet.insert(lens.id)
        }
    }

    func clearComparison() {
        comparisonSet.removeAll()
    }

    private func setupFilterPipeline() {
        let appDataPublisher = $appData.compactMap { $0 }

        Publishers.CombineLatest4(
            appDataPublisher,
            $allLensesSelectedFormat,
            $allLensesSelectedFocalCategory,
            $allLensesShowOnlyRentable
        )
        .debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
        .map { [weak self] appData, format, focalCategory, onlyRentable in
            self?.processLensesForGrouping(appData: appData, format: format, focalCategory: focalCategory, showOnlyRentable: onlyRentable) ?? []
        }
        .receive(on: DispatchQueue.main)
        .assign(to: \.groupedAndFilteredLenses, on: self)
        .store(in: &cancellables)
    }

    private func processLensesForGrouping(appData: AppData, format: String, focalCategory: FocalCategory, showOnlyRentable: Bool) -> [LensGroup] {
        let baseLenses: [Lens] = {
            if showOnlyRentable {
                let allRentableIDs = Set(appData.inventory.map(\.lens_id))
                return appData.lenses.filter { allRentableIDs.contains($0.id) }
            } else {
                return appData.lenses
            }
        }()

        let grouped = Dictionary(grouping: baseLenses, by: { normalizeName($0.manufacturer) })
            .map { key, lenses -> LensGroup in
                let manufacturer = lenses.first?.manufacturer ?? key
                let seriesDict = Dictionary(grouping: lenses, by: { normalizeName($0.lens_name) })
                let series = seriesDict.map { sKey, sLenses in
                    LensSeries(name: sLenses.first?.lens_name ?? sKey, lenses: sLenses)
                }
                    .sorted { $0.name < $1.name }
                return LensGroup(manufacturer: manufacturer, series: series)
            }
            .sorted { $0.manufacturer < $1.manufacturer }

        guard !format.isEmpty || focalCategory != .all else { return grouped }

        return grouped.compactMap { group in
            let filteredSeries = group.series.compactMap { series in
                let filtered = series.lenses.filter {
                    (format.isEmpty || $0.format == format) && focalCategory.contains(focal: $0.mainFocalValue)
                }
                return filtered.isEmpty ? nil : LensSeries(name: series.name, lenses: filtered)
            }
            return filteredSeries.isEmpty ? nil : LensGroup(manufacturer: group.manufacturer, series: filteredSeries)
        }
    }

    func groupLenses(forRental rentalId: String? = nil) -> [LensGroup] {
        let lenses = rentalId != nil ? lensesForRental(rentalId!) : availableLenses

        let grouped = Dictionary(grouping: lenses, by: { normalizeName($0.manufacturer) })
            .map { key, lenses in
                let manufacturer = lenses.first?.manufacturer ?? key
                let series = Dictionary(grouping: lenses, by: { normalizeName($0.lens_name) })
                    .map { sKey, sLenses in
                        LensSeries(name: sLenses.first?.lens_name ?? sKey, lenses: sLenses)
                    }
                    .sorted { $0.name < $1.name }

                return LensGroup(manufacturer: manufacturer, series: series)
            }
            .sorted { $0.manufacturer < $1.manufacturer }

        return grouped
    }

    func lensesForRental(_ rentalId: String) -> [Lens] {
        guard let appData = appData else { return [] }
        let lensIds = Set(appData.inventory.filter { $0.rental_id == rentalId }.map(\.lens_id))
        return appData.lenses.filter { lensIds.contains($0.id) }
    }

    func rentalsForLens(_ lensId: String) -> [Rental] {
        guard let appData else { return [] }

        let rentalIDs = Set(appData.inventory
            .filter { $0.lens_id == lensId }
            .map(\.rental_id)
        )

        return appData.rentals.filter { rentalIDs.contains($0.id) }
    }

    func lensDetails(for id: String) -> Lens? {
        appData?.lenses.first { $0.id == id }
    }

    func normalizeLensFormat(_ format: String) -> String {
        format.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "_", with: "")
            .capitalized
    }

    func normalizeFormat(_ format: String) -> String {
        format
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "  ", with: " ")
            .lowercased()
            .capitalized
    }

    func normalizeName(_ str: String) -> String {
        str.lowercased()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: "series", with: "", options: .caseInsensitive)
            .replacingOccurrences(of: "edition", with: "", options: .caseInsensitive)
    }
}