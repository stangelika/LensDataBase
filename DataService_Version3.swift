import Foundation
import Combine

// MARK: - Network Service

/// Network service for fetching data from remote APIs
class NetworkService {
    static let shared = NetworkService()
    
    private let LENS_DATA_URL = "https://script.google.com/macros/s/AKfycbzDzKQ3AU6ynZuPjET0NWqYMlDXMt5UKVPBOq9g7XurJKPoulWuPVVIl9U8eq_nSCG6/exec"
    private let CAMERA_DATA_URL = "https://script.google.com/macros/s/AKfycbz-2rLDrwQ7DPD3nOm7iGTvCISfIYggOVob2F43pgjR2UG3diztAaig6wO737m_Rh3GJw/exec"
    
    /// Network request timeout in seconds
    private let REQUEST_TIMEOUT: TimeInterval = 30.0
    
    /// URLSession configuration with timeout
    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = REQUEST_TIMEOUT
        config.timeoutIntervalForResource = REQUEST_TIMEOUT * 2
        return URLSession(configuration: config)
    }()
    
    /// Fetches lens data from the remote API
    /// - Returns: Publisher with AppData or Error
    func fetchLensData() -> AnyPublisher<AppData, Error> {
        return performRequest(urlString: LENS_DATA_URL, responseType: AppData.self)
            .handleEvents(
                receiveSubscription: { _ in
                    print("🌐 Starting lens data fetch...")
                },
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("✅ Lens data fetch completed successfully")
                    case .failure(let error):
                        print("❌ Lens data fetch failed: \(error.localizedDescription)")
                    }
                }
            )
            .eraseToAnyPublisher()
    }
    
    /// Fetches camera data from the remote API
    /// - Returns: Publisher with CameraApiResponse or Error
    func fetchCameraData() -> AnyPublisher<CameraApiResponse, Error> {
        return performRequest(urlString: CAMERA_DATA_URL, responseType: CameraApiResponse.self)
            .handleEvents(
                receiveSubscription: { _ in
                    print("🌐 Starting camera data fetch...")
                },
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("✅ Camera data fetch completed successfully")
                    case .failure(let error):
                        print("❌ Camera data fetch failed: \(error.localizedDescription)")
                    }
                }
            )
            .eraseToAnyPublisher()
    }
    
    /// Generic network request method
    /// - Parameters:
    ///   - urlString: URL string to fetch from
    ///   - responseType: Expected response type
    /// - Returns: Publisher with response or error
    private func performRequest<T: Decodable>(
        urlString: String,
        responseType: T.Type
    ) -> AnyPublisher<T, Error> {
        guard let url = URL(string: urlString) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("LensDataBase/1.0", forHTTPHeaderField: "User-Agent")
        
        return session.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw NetworkError.serverError(httpResponse.statusCode)
                }
                
                return data
            }
            .decode(type: responseType, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

// MARK: - Network Errors

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(Int)
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .serverError(let code):
            return "Server error with code: \(code)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        }
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
    
    /// Groups lenses by manufacturer and series with caching
    /// - Parameter rentalId: Optional rental ID to filter lenses
    /// - Returns: Array of grouped lenses
    func groupLenses(forRental rentalId: String? = nil) -> [LensGroup] {
        let lenses = rentalId != nil ? lensesForRental(rentalId!) : availableLenses
        
        // Create a dictionary to group by manufacturer
        var manufacturerGroups = [String: [Lens]]()
        
        for lens in lenses {
            let normalizedManufacturer = normalizeName(lens.manufacturer)
            manufacturerGroups[normalizedManufacturer, default: []].append(lens)
        }
        
        // Convert to LensGroup objects
        return manufacturerGroups.compactMap { (normalizedName, lenses) in
            guard let firstLens = lenses.first else { return nil }
            
            // Group lenses by series within manufacturer
            var seriesGroups = [String: [Lens]]()
            for lens in lenses {
                let normalizedSeries = normalizeName(lens.lens_name)
                seriesGroups[normalizedSeries, default: []].append(lens)
            }
            
            // Convert to LensSeries objects
            let series = seriesGroups.compactMap { (normalizedName, seriesLenses) in
                guard let firstSeriesLens = seriesLenses.first else { return nil }
                return LensSeries(
                    name: firstSeriesLens.lens_name,
                    lenses: seriesLenses.sorted { $0.focal_length < $1.focal_length }
                )
            }.sorted { $0.name < $1.name }
            
            return LensGroup(
                manufacturer: firstLens.manufacturer,
                series: series
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
    
    /// Normalizes a string for comparison with better unicode handling
    /// - Parameter str: The string to normalize
    /// - Returns: Normalized string
    private func normalizeName(_ str: String) -> String {
        return str
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: "series", with: "", options: .caseInsensitive)
            .replacingOccurrences(of: "edition", with: "", options: .caseInsensitive)
            .trimmingCharacters(in: .whitespacesAndNewlines)
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
    
    /// Searches lenses by name with optional filters
    /// - Parameters:
    ///   - searchText: Text to search for in lens names
    ///   - format: Optional format filter
    ///   - focalCategory: Optional focal length category filter
    /// - Returns: Array of filtered lenses
    func searchLenses(
        searchText: String = "",
        format: String = "",
        focalCategory: FocalCategory = .all
    ) -> [Lens] {
        return availableLenses.filter { lens in
            let searchMatches = searchText.isEmpty || 
                lens.lens_name.localizedCaseInsensitiveContains(searchText) ||
                lens.display_name.localizedCaseInsensitiveContains(searchText) ||
                lens.manufacturer.localizedCaseInsensitiveContains(searchText)
            
            let formatMatches = format.isEmpty || lens.format == format
            let focalMatches = focalCategory.contains(focal: lens.mainFocalValue)
            
            return searchMatches && formatMatches && focalMatches
        }
    }
    
    /// Gets available formats from current lens data
    /// - Returns: Array of unique formats sorted alphabetically
    func getAvailableFormats() -> [String] {
        return Array(Set(availableLenses.map { $0.format }))
            .filter { !$0.isEmpty }
            .sorted()
    }
    
    /// Gets available manufacturers from current lens data
    /// - Returns: Array of unique manufacturers sorted alphabetically
    func getAvailableManufacturers() -> [String] {
        return Array(Set(availableLenses.map { $0.manufacturer }))
            .filter { !$0.isEmpty }
            .sorted()
    }
}