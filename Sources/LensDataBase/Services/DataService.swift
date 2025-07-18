import Foundation

#if canImport(Combine)
    import Combine

    // MARK: - Network Service

    /// Network service for fetching lens and camera data from remote APIs
    class NetworkService {
        static let shared = NetworkService()

        private let lensDataURL = "https://script.google.com/macros/s/AKfycbzDzKQ3AU6ynZuPjET0NWqYMlDXMt5UKVPBOq9g7XurJKPoulWuPVVIl9U8eq_nSCG6/exec"
        private let cameraDataURL = "https://script.google.com/macros/s/AKfycbz-2rLDrwQ7DPD3nOm7iGTvCISfIYggOVob2F43pgjR2UG3diztAaig6wO737m_Rh3GJw/exec"

        /// Fetches lens data from the remote API
        /// - Returns: Publisher that emits AppData or an error
        func fetchLensData() -> AnyPublisher<AppData, Error> {
            guard let dataURL = URL(string: lensDataURL) else {
                return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
            }

            return URLSession.shared.dataTaskPublisher(for: dataURL)
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
            guard let dataURL = URL(string: cameraDataURL) else {
                return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
            }

            return URLSession.shared.dataTaskPublisher(for: dataURL)
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
        @Published var favoriteLenses: Set<String> = []
        @Published var favoriteLensesList: [Lens] = []
        @Published var selectedRentalId = ""

        private var cancellables = Set<AnyCancellable>()
        private let favoritesKey = "favoriteLenses"

        /// Initializes the data manager and loads favorites
        init() {
            loadFavorites()
        }

        /// Loads data from local resources or remote API
        func loadData() {
            loadingState = .loading

            // Try to load from local resources first
            if let localData = loadLocalData() {
                self.appData = localData
                self.availableLenses = localData.lenses
                self.updateFavoriteLensesList()
                self.loadingState = .loaded
            } else {
                // Fall back to remote API
                NetworkService.shared.fetchLensData()
                    .sink(
                        receiveCompletion: { [weak self] completion in
                            if case .failure(let error) = completion {
                                self?.loadingState = .error("Failed to load data: \(error.localizedDescription)")
                            }
                        },
                        receiveValue: { [weak self] data in
                            self?.appData = data
                            self?.availableLenses = data.lenses
                            self?.updateFavoriteLensesList()
                            self?.loadingState = .loaded
                        })
                    .store(in: &cancellables)
            }
        }

        /// Loads camera data from the remote API
        func loadCameraData() {
            NetworkService.shared.fetchCameraData()
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            print("Failed to load camera data: \(error)")
                        }
                    },
                    receiveValue: { [weak self] data in
                        self?.cameras = data.camera
                        self?.formats = data.formats
                    })
                .store(in: &cancellables)
        }

        /// Loads data from local JSON resources
        private func loadLocalData() -> AppData? {
            guard
                let path = Bundle.main.path(forResource: "lens_data", ofType: "json"),
                let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
                return nil
            }

            return try? JSONDecoder().decode(AppData.self, from: data)
        }

        // MARK: - Favorites Management

        /// Updates the favorite lenses list based on current favorites
        private func updateFavoriteLensesList() {
            favoriteLensesList = availableLenses.filter { favoriteLenses.contains($0.id) }
        }

        /// Saves favorites to UserDefaults
        private func saveFavorites() {
            let favoritesArray = Array(favoriteLenses)
            UserDefaults.standard.set(favoritesArray, forKey: favoritesKey)
        }

        /// Loads favorites from UserDefaults
        private func loadFavorites() {
            guard let favoritesArray = UserDefaults.standard.array(forKey: favoritesKey) as? [String] else { return }
            favoriteLenses = Set(favoritesArray)
        }

        /// Toggles favorite status for a lens
        /// - Parameter lens: The lens to toggle
        func toggleFavorite(lens: Lens) {
            if favoriteLenses.contains(lens.id) {
                favoriteLenses.remove(lens.id)
            } else {
                favoriteLenses.insert(lens.id)
            }
            saveFavorites()
            updateFavoriteLensesList()
        }

        /// Checks if a lens is marked as favorite
        /// - Parameter lens: The lens to check
        /// - Returns: True if the lens is a favorite
        func isFavorite(lens: Lens) -> Bool {
            favoriteLenses.contains(lens.id)
        }

        // MARK: - Lens Grouping

        /// Groups lenses by manufacturer and series
        /// - Parameter lenses: The lenses to group
        /// - Returns: Array of lens groups
        func groupLenses(_ lenses: [Lens]) -> [LensGroup] {
            let grouped = Dictionary(grouping: lenses) { $0.manufacturer }

            return grouped.map { manufacturer, lenses in
                let series = Dictionary(grouping: lenses) { lens in
                    // Extract series name from lens name (simplified logic)
                    let components = lens.lensName.components(separatedBy: " ")
                    return components.first ?? "Other"
                }

                let lensSeries = series.map { seriesName, seriesLenses in
                    LensSeries(name: seriesName, lenses: seriesLenses.sorted { $0.displayName < $1.displayName })
                }.sorted { $0.name < $1.name }

                return LensGroup(manufacturer: manufacturer, series: lensSeries)
            }.sorted { $0.manufacturer < $1.manufacturer }
        }
    }

#else

    // MARK: - Non-Combine Data Manager

    /// Simplified data manager for platforms without Combine support
    class DataManager {
        var appData: AppData?
        var loadingState: DataLoadingState = .idle
        var availableLenses: [Lens] = []
        var cameras: [Camera] = []
        var formats: [RecordingFormat] = []
        var activeTab: ActiveTab = .allLenses
        var favoriteLenses: Set<String> = []
        var favoriteLensesList: [Lens] = []
        var selectedRentalId = ""

        private let favoritesKey = "favoriteLenses"

        init() {
            loadFavorites()
        }

        func loadData() {
            loadingState = .loading

            if let localData = loadLocalData() {
                self.appData = localData
                self.availableLenses = localData.lenses
                self.updateFavoriteLensesList()
                self.loadingState = .loaded
            } else {
                loadingState = .error("No local data available")
            }
        }

        private func loadLocalData() -> AppData? {
            // Implementation would depend on platform
            nil
        }

        private func updateFavoriteLensesList() {
            favoriteLensesList = availableLenses.filter { favoriteLenses.contains($0.id) }
        }

        private func saveFavorites() {
            let favoritesArray = Array(favoriteLenses)
            UserDefaults.standard.set(favoritesArray, forKey: favoritesKey)
        }

        private func loadFavorites() {
            guard let favoritesArray = UserDefaults.standard.array(forKey: favoritesKey) as? [String] else { return }
            favoriteLenses = Set(favoritesArray)
        }

        func toggleFavorite(lens: Lens) {
            if favoriteLenses.contains(lens.id) {
                favoriteLenses.remove(lens.id)
            } else {
                favoriteLenses.insert(lens.id)
            }
            saveFavorites()
            updateFavoriteLensesList()
        }

        func isFavorite(lens: Lens) -> Bool {
            favoriteLenses.contains(lens.id)
        }

        func groupLenses(_ lenses: [Lens]) -> [LensGroup] {
            let grouped = Dictionary(grouping: lenses) { $0.manufacturer }

            return grouped.map { manufacturer, lenses in
                let series = Dictionary(grouping: lenses) { lens in
                    let components = lens.lensName.components(separatedBy: " ")
                    return components.first ?? "Other"
                }

                let lensSeries = series.map { seriesName, seriesLenses in
                    LensSeries(name: seriesName, lenses: seriesLenses.sorted { $0.displayName < $1.displayName })
                }.sorted { $0.name < $1.name }

                return LensGroup(manufacturer: manufacturer, series: lensSeries)
            }.sorted { $0.manufacturer < $1.manufacturer }
        }
    }

#endif
