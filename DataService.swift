// DataService.swift

import Combine
import Foundation

// MARK: - Network Service

/// Network service for fetching lens and camera data from remote APIs
class NetworkService {
    static let shared = NetworkService()

    private let lensDataURL = "https://script.google.com/macros/s/AKfycbzDzKQ3AU6ynZuPjET0NWqYMlDXMt5UKVPBOq9g7XurJKPoulWuPVVIl9U8eq_nSCG6/exec"
    private let cameraDataURL = "https://script.google.com/macros/s/AKfycbz-2rLDrwQ7DPD3nOm7iGTvCISfIYggOVob2F43pgjR2UG3diztAaig6wO737m_Rh3GJw/exec"

    /// Fetches lens data from the remote API
    /// - Returns: Publisher that emits AppData or an error
    func fetchLensData() -> AnyPublisher<AppData, Error> {
        guard let requestURL = URL(string: lensDataURL) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: requestURL)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: AppData.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    /// Fetches camera data from the remote API
    /// - Returns: Publisher that emits CameraApiResponse or an error
    func fetchCameraData() -> AnyPublisher<CameraApiResponse, Error> {
        guard let requestURL = URL(string: cameraDataURL) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: requestURL)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: CameraApiResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

// MARK: - Data Manager

/// Central data manager for the application, handling data loading, favorites, and state management
class DataManager: ObservableObject {
    @Published var appData: AppData?
    @Published var loadingState: DataLoadingState = .idle
    @Published var availableLenses: [Lens] = []

    @Published var cameras: [Camera] = []
    @Published var formats: [RecordingFormat] = []

    @Published var activeTab: ActiveTab = .allLenses
    @Published var selectedRentalId: String = ""

    // Properties for new features and favorite lens management
    /// Set of favorite lens IDs
    @Published var favoriteLenses = Set<String>()
    @Published var comparisonSet = Set<String>()

    @Published var favoriteLensesList: [Lens] = []

    private var cancellables = Set<AnyCancellable>()
    private let favoritesKey = "favoriteLenses"

    /// Initializes the data manager and loads saved favorites
    init() {
        loadFavorites()
    }

    // MARK: - Favorites Management

    /// Updates the favorite lenses list based on current favorites
    private func updateFavoriteLensesList() {
        favoriteLensesList = availableLenses
            .filter { favoriteLenses.contains($0.id) }
            .sorted { $0.display_name < $1.display_name }
    }

    /// Saves favorites to UserDefaults
    private func saveFavorites() {
        // UserDefaults doesn't support Set directly, so convert to Array
        let favoritesArray = Array(favoriteLenses)
        UserDefaults.standard.set(favoritesArray, forKey: favoritesKey)
    }

    /// Loads favorites from UserDefaults
    private func loadFavorites() {
        guard let favoritesArray = UserDefaults.standard.array(forKey: favoritesKey) as? [String] else {
            return
        }
        // Convert back to Set
        favoriteLenses = Set(favoritesArray)
    }

    /// Checks if a lens is marked as favorite
    /// - Parameter lens: The lens to check
    /// - Returns: True if the lens is a favorite, false otherwise
    func isFavorite(lens: Lens) -> Bool {
        favoriteLenses.contains(lens.id)
    }

    /// Toggles favorite status for a lens
    /// - Parameter lens: The lens to toggle favorite status for
    func toggleFavorite(lens: Lens) {
        if isFavorite(lens: lens) {
            favoriteLenses.remove(lens.id)
        } else {
            favoriteLenses.insert(lens.id)
        }
        saveFavorites() // Save changes after each toggle
        updateFavoriteLensesList()
    }

    // MARK: - Comparison Logic

    func isInComparison(lens: Lens) -> Bool { comparisonSet.contains(lens.id) }

    func toggleComparison(lens: Lens) {
        if !isInComparison(lens: lens), comparisonSet.count >= 4 { return }
        if isInComparison(lens: lens) {
            comparisonSet.remove(lens.id)
        } else {
            comparisonSet.insert(lens.id)
        }
    }

    func clearComparison() {
        comparisonSet.removeAll()
    }

    // MARK: - Data Loading

    /// Loads data from local JSON files
    func loadData() {
        guard loadingState == .idle else { return }
        loadingState = .loading

        let lensPublisher = loadLocalJSON(from: "LENSDATA") as AnyPublisher<AppData, Error>
        let cameraPublisher = loadLocalJSON(from: "CAMERADATA") as AnyPublisher<CameraApiResponse, Error>

        Publishers.Zip(lensPublisher, cameraPublisher)
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.loadingState = .error(error.localizedDescription)
                }
            }, receiveValue: { [weak self] appData, cameraData in
                guard let self else { return }
                self.appData = appData
                collectAvailableLenses()
                cameras = cameraData.camera.sorted { $0.manufacturer < $1.manufacturer }
                formats = cameraData.formats
                loadingState = .loaded

                updateFavoriteLensesList()
                print("✅ Local data loaded successfully!")
            })
            .store(in: &cancellables)
    }

    /// Refreshes data from remote API
    func refreshDataFromAPI() {
        loadingState = .loading

        NetworkService.shared.fetchLensData()
            .flatMap { [weak self] appData -> AnyPublisher<CameraApiResponse, Error> in
                self?.appData = appData
                self?.collectAvailableLenses()
                return NetworkService.shared.fetchCameraData()
            }
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.loadingState = .error(error.localizedDescription)
                }
            }, receiveValue: { [weak self] cameraResponse in
                self?.cameras = cameraResponse.camera.sorted { $0.manufacturer < $1.manufacturer }
                self?.formats = cameraResponse.formats
                self?.loadingState = .loaded
            })
            .store(in: &cancellables)
    }

    /// Loads local JSON files from the app bundle
    /// - Parameter fileName: Name of the JSON file to load
    /// - Returns: Publisher that emits decoded data or an error
    private func loadLocalJSON<T: Decodable>(from fileName: String) -> AnyPublisher<T, Error> {
        guard let requestURL = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            return Fail(error: URLError(.fileDoesNotExist)).eraseToAnyPublisher()
        }

        return Just(requestURL)
            .tryMap { try Data(contentsOf: $0) }
            .decode(type: T.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    // MARK: - Helper Functions

    /// Collects available lenses from inventory
    private func collectAvailableLenses() {
        guard let appData else { return }

        let lensIds = Set(appData.inventory.values.flatMap { $0.map(\.lens_id) })
        availableLenses = appData.lenses.filter { lensIds.contains($0.id) }
    }

    /// Groups lenses by manufacturer and series for UI display
    /// - Parameter rentalId: Optional rental ID to filter lenses for specific rental
    /// - Returns: Array of grouped lenses
    func groupLenses(forRental rentalId: String? = nil) -> [LensGroup] {
        let lenses = rentalId.map { lensesForRental($0) } ?? availableLenses

        let normalizedManufacturers = lenses.reduce(into: [String: [Lens]]()) { result, lens in
            let normalized = normalizeName(lens.manufacturer)
            result[normalized, default: []].append(lens)
        }

        return normalizedManufacturers.map { manufacturerKey, lenses in
            let originalManufacturer = lenses.first?.manufacturer ?? manufacturerKey

            let normalizedSeries = lenses.reduce(into: [String: [Lens]]()) { result, lens in
                let normalized = normalizeName(lens.lens_name)
                result[normalized, default: []].append(lens)
            }

            let series = normalizedSeries.map { seriesKey, lenses in
                let originalSeriesName = lenses.first?.lens_name ?? seriesKey
                return LensSeries(name: originalSeriesName, lenses: lenses)
            }
            .sorted { $0.name < $1.name }

            return LensGroup(manufacturer: originalManufacturer, series: series.sorted { $0.name < $1.name })
        }
        .sorted { $0.manufacturer < $1.manufacturer }
    }

    /// Gets lenses available for a specific rental
    /// - Parameter rentalId: The rental ID to get lenses for
    /// - Returns: Array of lenses available at that rental
    private func lensesForRental(_ rentalId: String) -> [Lens] {
        guard let appData,
              let inventory = appData.inventory[rentalId] else { return [] }

        let lensIds = inventory.map(\.lens_id)
        return appData.lenses.filter { lensIds.contains($0.id) }
    }

    /// Normalizes names for grouping (removes spaces, special characters, etc.)
    /// - Parameter str: The string to normalize
    /// - Returns: Normalized string
    private func normalizeName(_ inputString: String) -> String {
        inputString
            .lowercased()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: "series", with: "", options: .caseInsensitive)
            .replacingOccurrences(of: "edition", with: "", options: .caseInsensitive)
    }

    /// Gets lens details by ID
    /// - Parameter id: The lens ID to search for
    /// - Returns: Lens object if found, nil otherwise
    func lensDetails(for id: String) -> Lens? {
        appData?.lenses.first { $0.id == id }
    }

    /// Gets rentals that have a specific lens in their inventory
    /// - Parameter lensId: The lens ID to search for
    /// - Returns: Array of rentals that have this lens
    func rentalsForLens(_ lensId: String) -> [Rental] {
        guard let appData else { return [] }

        return appData.inventory.compactMap { rentalId, items in
            if items.contains(where: { $0.lens_id == lensId }) {
                return appData.rentals.first { $0.id == rentalId }
            }
            return nil
        }
    }
}
