import Foundation
import Combine

// MARK: - Network Service

/// Network service for fetching data from remote APIs
class NetworkService {
    static let shared = NetworkService()
    
    private let LENS_DATA_URL = "https://script.google.com/macros/s/AKfycbzDzKQ3AU6ynZuPjET0NWqYMlDXMt5UKVPBOq9g7XurJKPoulWuPVVIl9U8eq_nSCG6/exec"
    private let CAMERA_DATA_URL = "https://script.google.com/macros/s/AKfycbz-2rLDrwQ7DPD3nOm7iGTvCISfIYggOVob2F43pgjR2UG3diztAaig6wO737m_Rh3GJw/exec"
    
    /// Fetches lens data from the remote API
    /// - Returns: Publisher with AppData or Error
    func fetchLensData() -> AnyPublisher<AppData, Error> {
        guard let url = URL(string: LENS_DATA_URL) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: AppData.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    /// Fetches camera data from the remote API
    /// - Returns: Publisher with CameraApiResponse or Error
    func fetchCameraData() -> AnyPublisher<CameraApiResponse, Error> {
        guard let url = URL(string: CAMERA_DATA_URL) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
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

/// Main data manager for the application
class DataManager: ObservableObject {
    // MARK: - Published Properties
    
    @Published var appData: AppData?
    @Published var loadingState: DataLoadingState = .idle
    @Published var availableLenses: [Lens] = []
    @Published var cameras: [Camera] = []
    @Published var formats: [RecordingFormat] = []
    @Published var activeTab: ActiveTab = .allLenses
    @Published var selectedRentalId: String = ""
    @Published var favoriteLenses = Set<String>()
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    private let favoritesKey = "favoriteLenses"

    // MARK: - Initialization
    
    /// Initializes the data manager and loads favorites from storage
    init() {
        loadFavorites()
    }
    
    // MARK: - Favorites Management
    
    /// Saves favorite lenses to UserDefaults
    private func saveFavorites() {
        let favoritesArray = Array(favoriteLenses)
        UserDefaults.standard.set(favoritesArray, forKey: favoritesKey)
    }

    /// Loads favorite lenses from UserDefaults
    private func loadFavorites() {
        guard let favoritesArray = UserDefaults.standard.array(forKey: favoritesKey) as? [String] else {
            return
        }
        self.favoriteLenses = Set(favoritesArray)
    }

    /// Checks if a lens is marked as favorite
    /// - Parameter lens: The lens to check
    /// - Returns: True if the lens is a favorite, false otherwise
    func isFavorite(lens: Lens) -> Bool {
        return favoriteLenses.contains(lens.id)
    }

    /// Toggles the favorite status of a lens
    /// - Parameter lens: The lens to toggle
    func toggleFavorite(lens: Lens) {
        if isFavorite(lens: lens) {
            favoriteLenses.remove(lens.id)
        } else {
            favoriteLenses.insert(lens.id)
        }
        saveFavorites()
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
                if case .failure(let error) = completion {
                    self?.loadingState = .error(error.localizedDescription)
                    print("❌ Error loading local data: \(error)")
                }
            }, receiveValue: { [weak self] (appData, cameraData) in
                self?.appData = appData
                self?.collectAvailableLenses()
                self?.cameras = cameraData.camera.sorted { $0.manufacturer < $1.manufacturer }
                self?.formats = cameraData.formats
                
                self?.loadingState = .loaded
                print("✅ Local data loaded successfully!")
            })
            .store(in: &cancellables)
    }

    /// Refreshes data from remote API
    func refreshDataFromAPI() {
        print("Starting data refresh from server...")
        loadingState = .loading
        
        NetworkService.shared.fetchLensData()
            .flatMap { [weak self] appData -> AnyPublisher<CameraApiResponse, Error> in
                self?.appData = appData
                self?.collectAvailableLenses()
                return NetworkService.shared.fetchCameraData()
            }
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.loadingState = .error(error.localizedDescription)
                    print("❌ Error refreshing data from server: \(error)")
                }
            }, receiveValue: { [weak self] cameraResponse in
                self?.cameras = cameraResponse.camera.sorted { $0.manufacturer < $1.manufacturer }
                self?.formats = cameraResponse.formats
                self?.loadingState = .loaded
                print("✅ Data from server refreshed successfully!")
            })
            .store(in: &cancellables)
    }

    /// Loads local JSON data from bundle
    /// - Parameter fileName: The name of the JSON file (without extension)
    /// - Returns: Publisher with decoded data or error
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
    
    // MARK: - Helper Methods
    
    /// Collects available lenses from inventory
    private func collectAvailableLenses() {
        guard let appData = appData else { return }
        
        let lensIds = Set(appData.inventory.values.flatMap { $0.map { $0.lens_id } })
        availableLenses = appData.lenses.filter { lensIds.contains($0.id) }
    }
    
    /// Groups lenses by manufacturer and series
    /// - Parameter rentalId: Optional rental ID to filter lenses
    /// - Returns: Array of grouped lenses
    func groupLenses(forRental rentalId: String? = nil) -> [LensGroup] {
        let lenses = rentalId != nil ? lensesForRental(rentalId!) : availableLenses
        
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
            }.sorted { $0.name < $1.name }
            
            return LensGroup(
                manufacturer: originalManufacturer,
                series: series.sorted { $0.name < $1.name }
            )
        }.sorted { $0.manufacturer < $1.manufacturer }
    }
    
    /// Gets lenses for a specific rental
    /// - Parameter rentalId: The rental ID
    /// - Returns: Array of lenses available for the rental
    private func lensesForRental(_ rentalId: String) -> [Lens] {
        guard let appData = appData,
              let inventory = appData.inventory[rentalId] else { return [] }
        
        let lensIds = inventory.map { $0.lens_id }
        return appData.lenses.filter { lensIds.contains($0.id) }
    }
    
    /// Normalizes a string for comparison
    /// - Parameter str: The string to normalize
    /// - Returns: Normalized string
    private func normalizeName(_ str: String) -> String {
        return str
            .lowercased()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: "series", with: "", options: .caseInsensitive)
            .replacingOccurrences(of: "edition", with: "", options: .caseInsensitive)
    }
    
    /// Gets lens details by ID
    /// - Parameter id: The lens ID
    /// - Returns: Lens if found, nil otherwise
    func lensDetails(for id: String) -> Lens? {
        return appData?.lenses.first { $0.id == id }
    }
    
    /// Gets rentals that have a specific lens
    /// - Parameter lensId: The lens ID
    /// - Returns: Array of rentals that have the lens
    func rentalsForLens(_ lensId: String) -> [Rental] {
        guard let appData = appData else { return [] }
        
        return appData.inventory.compactMap { rentalId, items in
            if items.contains(where: { $0.lens_id == lensId }) {
                return appData.rentals.first { $0.id == rentalId }
            }
            return nil
        }.compactMap { $0 }
    }
}