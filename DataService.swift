
import Combine
import Foundation

class NetworkService {
    static let shared = NetworkService()

    private let LENS_DATA_URL = "https://script.google.com/macros/s/AKfycbzDzKQ3AU6ynZuPjET0NWqYMlDXMt5UKVPBOq9g7XurJKPoulWuPVVIl9U8eq_nSCG6/exec"

    func fetchLensData() -> AnyPublisher<AppData, Error> {
        guard let url = URL(string: LENS_DATA_URL) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: url)
        .tryMap {
            data, response in
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode    == 200 else {
                throw URLError(.badServerResponse)
            }
            return data
        }
        .decode(type: AppData.self, decoder: JSONDecoder())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

}
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
    private func updateFavoriteLensesList() {
        favoriteLensesList = availableLenses
        .filter {
            favoriteLenses.contains($0.id)
        }
        .sorted {
            $0.display_name < $1.display_name
        }

    }
    private func saveFavorites() {
        let favoritesArray = Array(favoriteLenses)
        UserDefaults.standard.set(favoritesArray, forKey: favoritesKey)
    }
    private func loadFavorites() {
        guard let favoritesArray = UserDefaults.standard.array(forKey: favoritesKey) as? [String] else {
            return
        }
        favoriteLenses = Set(favoritesArray)
        updateFavoriteLensesList()
    }
    func isFavorite(lens: Lens) -> Bool {
        favoriteLenses.contains(lens.id)
    }
    func toggleFavorite(lens: Lens) {
        if isFavorite(lens: lens) {
            favoriteLenses.remove(lens.id)
        }
        else {
            favoriteLenses.insert(lens.id)
        }
        saveFavorites()
        updateFavoriteLensesList()
    }
    func isInComparison(lens: Lens) -> Bool {
        comparisonSet.contains(lens.id)
    }
    func toggleComparison(lens: Lens) {
        if !isInComparison(lens: lens), comparisonSet.count   >= 4 {
            return
        }
        if isInComparison(lens: lens) {
            comparisonSet.remove(lens.id)
        }
        else {
            comparisonSet.insert(lens.id)
        }

    }
    func clearComparison() {
        comparisonSet.removeAll()
    }
    func loadData() {
        guard loadingState    == .idle else {
            return
        }
        loadingState = .loading

        let lensPublisher = loadLocalJSON(from: "LENSDATA") as AnyPublisher<AppData, Error>
        let cameraPublisher = loadLocalJSON(from: "CAMERADATA") as AnyPublisher<CameraApiResponse, Error>

        Publishers.Zip(lensPublisher, cameraPublisher)
        .sink(receiveCompletion: {
            [weak self] completion in
            if case let .failure(error) = completion {
                self? .loadingState = .error(error.localizedDescription)
            }

        }, receiveValue: {
            [weak self] appData, cameraData in
            guard let self else {
                return
            }
            self.appData = appData
            self.collectAvailableLenses()
            self.updateFavoriteLensesList()
            self.cameras = cameraData.camera.sorted {
                $0.manufacturer < $1.manufacturer
            }
            self.formats = cameraData.formats
            self.loadingState = .loaded

            print("✅ Локальные данные успешно загружены!")
        }
        )
        .store(in: &cancellables)
    }
    func refreshDataFromAPI() {
        print("Начинаем обновление данных линз с сервера...")
        loadingState = .loading

        NetworkService.shared.fetchLensData()
        .sink(receiveCompletion: {
            [weak self] completion in
            if case let .failure(error) = completion {
                self? .loadingState = .error(error.localizedDescription)
                print("❌ Ошибка при обновлении данных линз с сервера: \(error)")
            }
            else if case .finished = completion {
                self? .loadingState = .loaded
                print("✅ Данные линз с сервера успешно обновлены!")
            }

        }, receiveValue: {
            [weak self] appData in
            self? .appData = appData
            self?.collectAvailableLenses()
            self?.updateFavoriteLensesList()
        }
        )
        .store(in: &cancellables)
    }
    private func loadLocalJSON<T: Decodable>(from fileName: String) -> AnyPublisher<T, Error> {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            return Fail(error: URLError(.fileDoesNotExist)).eraseToAnyPublisher()
        }
        return Just(url)
        .tryMap {
            try Data(contentsOf: $0)
        }
        .decode(type: T.self, decoder: JSONDecoder())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    private func setupFilterPipeline() {
        let appDataPublisher = $appData.compactMap {
            $0
        }
        let filterCombiner = Publishers.CombineLatest4(
        appDataPublisher, $allLensesSelectedFormat, $allLensesSelectedFocalCategory, $allLensesShowOnlyRentable
        )
        .debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
        .receive(on: DispatchQueue.global(qos: .userInitiated))

        filterCombiner
        .map {
            [weak self] appData, format, focalCategory, showOnlyRentable in
            self?.processLensesForGrouping(appData: appData, format: format, focalCategory: focalCategory, showOnlyRentable: showOnlyRentable) ?? []
        }
        .receive(on: DispatchQueue.main)
        .assign(to: \.groupedAndFilteredLenses, on: self)
        .store(in: &cancellables)
    }
    private func processLensesForGrouping(appData: AppData, format: String, focalCategory: FocalCategory, showOnlyRentable: Bool) -> [LensGroup] {
        let baseLenses: [Lens]
        if showOnlyRentable {
            let allRentableLensIDs = Set(appData.inventory.values.flatMap {
                $0.map(\.lens_id)
            }
            )
            baseLenses = appData.lenses.filter {
                allRentableLensIDs.contains($0.id)
            }

        }
        else {
            baseLenses = appData.lenses
        }
        let normalizedManufacturers = baseLenses.reduce(into: [String: [Lens]]()) {
            result, lens in
            let normalized = self.normalizeName(lens.manufacturer)
            result[normalized, default: []].append(lens)
        }
        let initialGroups = normalizedManufacturers.map {
            manufacturerKey, lenses in
            let originalManufacturer = lenses.first? .manufacturer ?? manufacturerKey
            let normalizedSeries = lenses.reduce(into: [String: [Lens]]()) {
                result, lens in
                let normalized = self.normalizeName(lens.lens_name)
                result[normalized, default: []].append(lens)
            }
            let series = normalizedSeries.map {
                seriesKey, seriesLenses in
                let originalSeriesName = seriesLenses.first? .lens_name ?? seriesKey
                return LensSeries(name: originalSeriesName, lenses: seriesLenses)
            }
            .sorted {
                $0.name < $1.name
            }
            return LensGroup(manufacturer: originalManufacturer, series: series)
        }
        .sorted {
            $0.manufacturer < $1.manufacturer
        }
        guard !format.isEmpty || focalCategory    != .all else {
            return initialGroups
        }
        return initialGroups.compactMap {
            group in
            let filteredSeries = group.series.compactMap {
                series in
                let filteredLenses = series.lenses.filter {
                    (format.isEmpty || $0.format    == format) && focalCategory.contains(focal: $0.mainFocalValue)
                }
                return filteredLenses.isEmpty ? nil: LensSeries(name: series.name, lenses: filteredLenses)
            }
            return filteredSeries.isEmpty ? nil: LensGroup(manufacturer: group.manufacturer, series: filteredSeries)
        }

    }
    func collectAvailableLenses() {
        guard let appData else {
            return
        }
        availableLenses = appData.lenses
    }
    func groupLenses(forRental rentalId: String? = nil) -> [LensGroup] {
        let lenses = rentalId    != nil ? lensesForRental(rentalId!): availableLenses

        let normalizedManufacturers = lenses.reduce(into: [String: [Lens]]()) {
            result, lens in
            let normalized = normalizeName(lens.manufacturer)
            result[normalized, default: []].append(lens)
        }
        return normalizedManufacturers.map {
            manufacturerKey, lenses in
            let originalManufacturer = lenses.first? .manufacturer ?? manufacturerKey

            let normalizedSeries = lenses.reduce(into: [String: [Lens]]()) {
                result, lens in
                let normalized = normalizeName(lens.lens_name)
                result[normalized, default: []].append(lens)
            }
            let series = normalizedSeries.map {
                seriesKey, lenses in
                let originalSeriesName = lenses.first? .lens_name ?? seriesKey
                return LensSeries(name: originalSeriesName, lenses: lenses)
            }
            .sorted {
                $0.name < $1.name
            }
            return LensGroup(manufacturer: originalManufacturer, series: series.sorted {
                $0.name < $1.name
            }
            )
        }
        .sorted {
            $0.manufacturer < $1.manufacturer
        }

    }
    func lensesForRental(_ rentalId: String) -> [Lens] {
        guard let appData, let inventory = appData.inventory[rentalId] else {
            return []
        }
        let lensIds = inventory.map(\.lens_id)
        return appData.lenses.filter {
            lensIds.contains($0.id)
        }

    }
    func normalizeName(_ str: String) -> String {
        str
        .lowercased()
        .replacingOccurrences(of: " ", with: "")
        .replacingOccurrences(of: " - ", with: "")
        .replacingOccurrences(of: ".", with: "")
        .replacingOccurrences(of: "series", with: "", options: .caseInsensitive)
        .replacingOccurrences(of: "edition", with: "", options: .caseInsensitive)
    }
    func lensDetails(for id: String) -> Lens? {
        appData?.lenses.first {
            $0.id    == id
        }

    }
    func rentalsForLens(_ lensId: String) -> [Rental] {
        guard let appData else {
            return []
        }
        return appData.inventory.compactMap {
            rentalId, items in
            if items.contains(where: {
                $0.lens_id    == lensId
            }
            ) {
                return appData.rentals.first {
                    $0.id    == rentalId
                }

            }
            return nil
        }
        .compactMap {
            $0
        }

    }

}
