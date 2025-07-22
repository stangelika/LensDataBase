import Foundation

// MARK: - Repository Protocols

/// Repository for lens data operations
protocol LensRepositoryProtocol {
    func fetchAllLenses() async throws -> [Lens]
    func fetchLens(by id: String) async throws -> Lens?
    func searchLenses(query: String) async throws -> [Lens]
    func filterLenses(by criteria: LensFilterCriteria) async throws -> [Lens]
}

/// Repository for camera data operations
protocol CameraRepositoryProtocol {
    func fetchAllCameras() async throws -> [Camera]
    func fetchCamera(by id: String) async throws -> Camera?
    func fetchRecordingFormats() async throws -> [RecordingFormat]
}

/// Repository for rental data operations
protocol RentalRepositoryProtocol {
    func fetchAllRentals() async throws -> [Rental]
    func fetchRental(by id: String) async throws -> Rental?
    func fetchLensesForRental(rentalId: String) async throws -> [Lens]
    func fetchRentalsForLens(lensId: String) async throws -> [Rental]
}

/// Repository for user preferences and favorites
protocol UserPreferencesRepositoryProtocol {
    func getFavorites() async -> Set<String>
    func saveFavorites(_ favorites: Set<String>) async
    func toggleFavorite(lensId: String) async
    func isFavorite(lensId: String) async -> Bool
    
    func getComparisonSet() async -> Set<String>
    func saveComparisonSet(_ comparison: Set<String>) async
    func addToComparison(lensId: String) async throws
    func removeFromComparison(lensId: String) async
    func clearComparison() async
}

// MARK: - Filter Criteria

struct LensFilterCriteria {
    let format: String?
    let focalLengthCategory: FocalLengthCategory?
    let manufacturer: String?
    let searchQuery: String?
    let onlyRentable: Bool
    let minFocalLength: Double?
    let maxFocalLength: Double?
    let minAperture: Double?
    let maxAperture: Double?
    
    init(
        format: String? = nil,
        focalLengthCategory: FocalLengthCategory? = nil,
        manufacturer: String? = nil,
        searchQuery: String? = nil,
        onlyRentable: Bool = false,
        minFocalLength: Double? = nil,
        maxFocalLength: Double? = nil,
        minAperture: Double? = nil,
        maxAperture: Double? = nil
    ) {
        self.format = format
        self.focalLengthCategory = focalLengthCategory
        self.manufacturer = manufacturer
        self.searchQuery = searchQuery
        self.onlyRentable = onlyRentable
        self.minFocalLength = minFocalLength
        self.maxFocalLength = maxFocalLength
        self.minAperture = minAperture
        self.maxAperture = maxAperture
    }
}

// MARK: - Error Types

enum DomainError: Error, LocalizedError {
    case lensNotFound(String)
    case cameraNotFound(String)
    case rentalNotFound(String)
    case networkError(String)
    case dataCorrupted(String)
    case maxComparisonItemsReached
    
    var errorDescription: String? {
        switch self {
        case .lensNotFound(let id):
            return "Lens with ID '\(id)' not found"
        case .cameraNotFound(let id):
            return "Camera with ID '\(id)' not found"
        case .rentalNotFound(let id):
            return "Rental with ID '\(id)' not found"
        case .networkError(let message):
            return "Network error: \(message)"
        case .dataCorrupted(let message):
            return "Data corrupted: \(message)"
        case .maxComparisonItemsReached:
            return "Maximum comparison items reached (4 items max)"
        }
    }
}