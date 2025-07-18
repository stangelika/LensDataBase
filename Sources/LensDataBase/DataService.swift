import Foundation

#if canImport(Combine)
    import Combine
#endif

#if canImport(SwiftUI)
    import SwiftUI
#endif

// MARK: - Network Service

/// Network service for fetching lens and camera data from remote APIs
class NetworkService {
    static let shared = NetworkService()
    
    private let lensDataURL = "https://script.google.com/macros/s/AKfycbzDzKQ3AU6ynZuPjET0NWqYMlDXMt5UKVPBOq9g7XurJKPoulWuPVVIl9U8eq_nSCG6/exec"
    private let cameraDataURL = "https://script.google.com/macros/s/AKfycbz-2rLDrwQ7DPD3nOm7iGTvCISfIYggOVob2F43pgjR2UG3diztAaig6wO737m_Rh3GJw/exec"
    
    private init() {}
    
    #if canImport(Combine)
    /// Fetches lens data from the remote API
    /// - Returns: Publisher that emits AppData or an error
    func fetchLensData() -> AnyPublisher<AppData, Error> {
        guard let requestURL = URL(string: lensDataURL) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: requestURL)
            .map(\.data)
            .decode(type: AppData.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    /// Fetches camera data from the remote API
    /// - Returns: Publisher that emits CameraApiResponse or an error
    func fetchCameraData() -> AnyPublisher<CameraApiResponse, Error> {
        guard let requestURL = URL(string: cameraDataURL) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: requestURL)
            .map(\.data)
            .decode(type: CameraApiResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    #endif
}

// MARK: - Data Loading State

/// Enumeration representing the state of data loading
enum DataLoadingState {
    case idle
    case loading
    case loaded
    case error(String)
}

// MARK: - Active Tab

/// Enumeration representing the active tab in the app
enum ActiveTab {
    case allLenses
    case favorites
    case rental
    case update
}

#if canImport(SwiftUI)
/// Central data manager for the application, handling data loading, favorites, and state management
class DataManager: ObservableObject {
    @Published var appData: AppData?
    @Published var loadingState: DataLoadingState = .idle
    @Published var availableLenses: [Lens] = []
    
    @Published var cameras: [Camera] = []
    @Published var formats: [RecordingFormat] = []
    
    @Published var activeTab: ActiveTab = .allLenses
    
    // Favorites management
    @Published var favorites = Set<String>()
    
    // Comparison functionality
    @Published var comparisonSet = Set<String>()
    
    // Rental selection
    @Published var selectedRentalId: String = ""
    
    // Camera selection
    @Published var selectedCameraId: String = ""
    
    // Recording format selection
    @Published var selectedFormatId: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadFavoritesFromUserDefaults()
    }
    
    /// Loads data from the remote API
    func loadData() {
        loadingState = .loading
        
        NetworkService.shared.fetchLensData()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        self?.loadingState = .loaded
                    case .failure(let error):
                        self?.loadingState = .error(error.localizedDescription)
                    }
                },
                receiveValue: { [weak self] appData in
                    self?.appData = appData
                    self?.updateAvailableLenses()
                    self?.loadCameraData()
                }
            )
            .store(in: &cancellables)
    }
    
    /// Loads camera data
    private func loadCameraData() {
        NetworkService.shared.fetchCameraData()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] cameraResponse in
                    self?.cameras = cameraResponse.camera
                    self?.formats = cameraResponse.formats
                }
            )
            .store(in: &cancellables)
    }
    
    /// Updates available lenses based on inventory
    private func updateAvailableLenses() {
        guard let appData else { return }
        availableLenses = appData.lenses
    }
    
    /// Adds or removes a lens from favorites
    /// - Parameter lensId: The ID of the lens to toggle
    func toggleFavorite(lensId: String) {
        if favorites.contains(lensId) {
            favorites.remove(lensId)
        } else {
            favorites.insert(lensId)
        }
        saveFavoritesToUserDefaults()
    }
    
    /// Saves favorites to UserDefaults
    private func saveFavoritesToUserDefaults() {
        UserDefaults.standard.set(Array(favorites), forKey: "FavoriteLenses")
    }
    
    /// Loads favorites from UserDefaults
    private func loadFavoritesFromUserDefaults() {
        if let savedFavorites = UserDefaults.standard.array(forKey: "FavoriteLenses") as? [String] {
            favorites = Set(savedFavorites)
        }
    }
    
    /// Gets favorite lenses
    var favoriteLenses: [Lens] {
        availableLenses.filter { favorites.contains($0.id) }
    }
    
    /// Adds or removes a lens from comparison set
    /// - Parameter lensId: The ID of the lens to toggle
    func toggleComparison(lensId: String) {
        if comparisonSet.contains(lensId) {
            comparisonSet.remove(lensId)
        } else {
            comparisonSet.insert(lensId)
        }
    }
    
    /// Clears all lenses from comparison set
    func clearComparison() {
        comparisonSet.removeAll()
    }
}
#endif