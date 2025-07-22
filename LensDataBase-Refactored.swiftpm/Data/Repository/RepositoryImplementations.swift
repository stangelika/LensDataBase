import Foundation

// MARK: - Lens Repository Implementation

final class LensRepository: LensRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private var cachedLenses: [Lens] = []
    private var lastFetchTime: Date?
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func fetchAllLenses() async throws -> [Lens] {
        // Use cache if available and recent
        if let lastFetch = lastFetchTime,
           Date().timeIntervalSince(lastFetch) < 300, // 5 minutes
           !cachedLenses.isEmpty {
            return cachedLenses
        }
        
        let apiData = try await networkService.fetchLensData()
        cachedLenses = apiData.lenses.map { DomainMapper.mapToDomain(apiLens: $0) }
        lastFetchTime = Date()
        
        return cachedLenses
    }
    
    func fetchLens(by id: String) async throws -> Lens? {
        let lenses = try await fetchAllLenses()
        return lenses.first { $0.id == id }
    }
    
    func searchLenses(query: String) async throws -> [Lens] {
        let lenses = try await fetchAllLenses()
        guard !query.isEmpty else { return lenses }
        
        return lenses.filter { lens in
            lens.matches(filter: query)
        }
    }
    
    func filterLenses(by criteria: LensFilterCriteria) async throws -> [Lens] {
        let allLenses = try await fetchAllLenses()
        
        return allLenses.filter { lens in
            // Format filter
            if let format = criteria.format, !format.isEmpty {
                guard lens.format.lowercased().contains(format.lowercased()) else {
                    return false
                }
            }
            
            // Focal length category filter
            if let category = criteria.focalLengthCategory {
                guard category.contains(lens.specifications.focalLengthNumeric) else {
                    return false
                }
            }
            
            // Manufacturer filter
            if let manufacturer = criteria.manufacturer, !manufacturer.isEmpty {
                guard lens.manufacturer.lowercased().contains(manufacturer.lowercased()) else {
                    return false
                }
            }
            
            // Search query filter
            if let query = criteria.searchQuery, !query.isEmpty {
                guard lens.matches(filter: query) else {
                    return false
                }
            }
            
            // Focal length range filters
            if let minFocal = criteria.minFocalLength,
               let lensfocal = lens.specifications.focalLengthNumeric {
                guard lensfocal >= minFocal else { return false }
            }
            
            if let maxFocal = criteria.maxFocalLength,
               let lensfocal = lens.specifications.focalLengthNumeric {
                guard lensfocal <= maxFocal else { return false }
            }
            
            return true
        }
    }
}

// MARK: - Camera Repository Implementation

final class CameraRepository: CameraRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private var cachedCameras: [Camera] = []
    private var cachedFormats: [RecordingFormat] = []
    private var lastFetchTime: Date?
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func fetchAllCameras() async throws -> [Camera] {
        try await loadCameraData()
        return cachedCameras
    }
    
    func fetchCamera(by id: String) async throws -> Camera? {
        let cameras = try await fetchAllCameras()
        return cameras.first { $0.id == id }
    }
    
    func fetchRecordingFormats() async throws -> [RecordingFormat] {
        try await loadCameraData()
        return cachedFormats
    }
    
    private func loadCameraData() async throws {
        // Use cache if available and recent
        if let lastFetch = lastFetchTime,
           Date().timeIntervalSince(lastFetch) < 3600, // 1 hour
           !cachedCameras.isEmpty {
            return
        }
        
        let apiData = try await networkService.fetchCameraData()
        
        cachedFormats = apiData.formats.map { format in
            RecordingFormat(
                id: format.id,
                name: format.recordingFormat,
                width: format.recordingWidth,
                height: format.recordingHeight,
                imageCircle: format.recordingImageCircle
            )
        }
        
        cachedCameras = apiData.camera.map { camera in
            DomainMapper.mapToDomain(apiCamera: camera, formats: apiData.formats)
        }
        
        lastFetchTime = Date()
    }
}

// MARK: - Rental Repository Implementation

final class RentalRepository: RentalRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private let lensRepository: LensRepositoryProtocol
    private var cachedRentals: [Rental] = []
    private var cachedInventory: [APIInventoryItem] = []
    private var lastFetchTime: Date?
    
    init(networkService: NetworkServiceProtocol, lensRepository: LensRepositoryProtocol) {
        self.networkService = networkService
        self.lensRepository = lensRepository
    }
    
    func fetchAllRentals() async throws -> [Rental] {
        try await loadRentalData()
        return cachedRentals
    }
    
    func fetchRental(by id: String) async throws -> Rental? {
        let rentals = try await fetchAllRentals()
        return rentals.first { $0.id == id }
    }
    
    func fetchLensesForRental(rentalId: String) async throws -> [Lens] {
        try await loadRentalData()
        
        let lensIds = Set(cachedInventory
            .filter { $0.rental_id == rentalId }
            .map { $0.lens_id })
        
        let allLenses = try await lensRepository.fetchAllLenses()
        return allLenses.filter { lensIds.contains($0.id) }
    }
    
    func fetchRentalsForLens(lensId: String) async throws -> [Rental] {
        try await loadRentalData()
        
        let rentalIds = Set(cachedInventory
            .filter { $0.lens_id == lensId }
            .map { $0.rental_id })
        
        return cachedRentals.filter { rentalIds.contains($0.id) }
    }
    
    private func loadRentalData() async throws {
        // Use cache if available and recent
        if let lastFetch = lastFetchTime,
           Date().timeIntervalSince(lastFetch) < 300, // 5 minutes
           !cachedRentals.isEmpty {
            return
        }
        
        let apiData = try await networkService.fetchLensData()
        
        cachedInventory = apiData.inventory
        cachedRentals = apiData.rentals.map { rental in
            DomainMapper.mapToDomain(apiRental: rental, inventory: apiData.inventory)
        }
        
        lastFetchTime = Date()
    }
}

// MARK: - User Preferences Repository Implementation

final class UserPreferencesRepository: UserPreferencesRepositoryProtocol {
    private let userDefaults = UserDefaults.standard
    
    private enum Keys {
        static let favorites = "user_favorites"
        static let comparison = "user_comparison"
    }
    
    func getFavorites() async -> Set<String> {
        let array = userDefaults.array(forKey: Keys.favorites) as? [String] ?? []
        return Set(array)
    }
    
    func saveFavorites(_ favorites: Set<String>) async {
        userDefaults.set(Array(favorites), forKey: Keys.favorites)
    }
    
    func toggleFavorite(lensId: String) async {
        var favorites = await getFavorites()
        
        if favorites.contains(lensId) {
            favorites.remove(lensId)
        } else {
            favorites.insert(lensId)
        }
        
        await saveFavorites(favorites)
    }
    
    func isFavorite(lensId: String) async -> Bool {
        let favorites = await getFavorites()
        return favorites.contains(lensId)
    }
    
    func getComparisonSet() async -> Set<String> {
        let array = userDefaults.array(forKey: Keys.comparison) as? [String] ?? []
        return Set(array)
    }
    
    func saveComparisonSet(_ comparison: Set<String>) async {
        userDefaults.set(Array(comparison), forKey: Keys.comparison)
    }
    
    func addToComparison(lensId: String) async throws {
        var comparison = await getComparisonSet()
        
        guard comparison.count < 4 else {
            throw DomainError.maxComparisonItemsReached
        }
        
        comparison.insert(lensId)
        await saveComparisonSet(comparison)
    }
    
    func removeFromComparison(lensId: String) async {
        var comparison = await getComparisonSet()
        comparison.remove(lensId)
        await saveComparisonSet(comparison)
    }
    
    func clearComparison() async {
        await saveComparisonSet(Set())
    }
}