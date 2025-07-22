import Foundation

// MARK: - Use Cases

/// Use case for lens-related operations
protocol LensUseCaseProtocol {
    func getAllLenses() async throws -> [Lens]
    func searchLenses(query: String) async throws -> [Lens]
    func filterLenses(criteria: LensFilterCriteria) async throws -> [Lens]
    func getLensDetails(id: String) async throws -> Lens
    func groupLensesByManufacturer(_ lenses: [Lens]) -> [LensGroup]
}

/// Use case for favorites management
protocol FavoritesUseCaseProtocol {
    func getFavorites() async -> [Lens]
    func toggleFavorite(lens: Lens) async throws
    func isFavorite(lens: Lens) async -> Bool
}

/// Use case for lens comparison
protocol ComparisonUseCaseProtocol {
    func getComparisonLenses() async -> [Lens]
    func addToComparison(lens: Lens) async throws
    func removeFromComparison(lens: Lens) async throws
    func clearComparison() async throws
    func canAddToComparison() async -> Bool
}

/// Use case for camera-lens compatibility
protocol CompatibilityUseCaseProtocol {
    func checkCompatibility(lens: Lens, camera: Camera) async -> CompatibilityResult
    func getRecommendedCameras(for lens: Lens) async throws -> [Camera]
    func getCompatibleLenses(for camera: Camera) async throws -> [Lens]
}

/// Use case for rental operations
protocol RentalUseCaseProtocol {
    func getAllRentals() async throws -> [Rental]
    func getLensesForRental(rentalId: String) async throws -> [Lens]
    func getRentalsForLens(lensId: String) async throws -> [Rental]
}

// MARK: - Concrete Implementations

final class LensUseCase: LensUseCaseProtocol {
    private let lensRepository: LensRepositoryProtocol
    
    init(lensRepository: LensRepositoryProtocol) {
        self.lensRepository = lensRepository
    }
    
    func getAllLenses() async throws -> [Lens] {
        try await lensRepository.fetchAllLenses()
    }
    
    func searchLenses(query: String) async throws -> [Lens] {
        try await lensRepository.searchLenses(query: query)
    }
    
    func filterLenses(criteria: LensFilterCriteria) async throws -> [Lens] {
        try await lensRepository.filterLenses(by: criteria)
    }
    
    func getLensDetails(id: String) async throws -> Lens {
        guard let lens = try await lensRepository.fetchLens(by: id) else {
            throw DomainError.lensNotFound(id)
        }
        return lens
    }
    
    func groupLensesByManufacturer(_ lenses: [Lens]) -> [LensGroup] {
        let grouped = Dictionary(grouping: lenses) { lens in
            lens.manufacturer.normalizedForGrouping()
        }
        
        return grouped.compactMap { manufacturer, lenses in
            let seriesDict = Dictionary(grouping: lenses) { lens in
                lens.model.normalizedForGrouping()
            }
            
            let series = seriesDict.map { model, lenses in
                LensSeries(
                    name: lenses.first?.model ?? model,
                    lenses: lenses.sorted { $0.displayName < $1.displayName }
                )
            }.sorted { $0.name < $1.name }
            
            return LensGroup(
                manufacturer: lenses.first?.manufacturer ?? manufacturer,
                series: series
            )
        }.sorted { $0.manufacturer < $1.manufacturer }
    }
}

final class FavoritesUseCase: FavoritesUseCaseProtocol {
    private let userPreferencesRepository: UserPreferencesRepositoryProtocol
    private let lensRepository: LensRepositoryProtocol
    
    init(
        userPreferencesRepository: UserPreferencesRepositoryProtocol,
        lensRepository: LensRepositoryProtocol
    ) {
        self.userPreferencesRepository = userPreferencesRepository
        self.lensRepository = lensRepository
    }
    
    func getFavorites() async -> [Lens] {
        let favoriteIds = await userPreferencesRepository.getFavorites()
        let allLenses = (try? await lensRepository.fetchAllLenses()) ?? []
        return allLenses.filter { favoriteIds.contains($0.id) }
            .sorted { $0.displayName < $1.displayName }
    }
    
    func toggleFavorite(lens: Lens) async throws {
        await userPreferencesRepository.toggleFavorite(lensId: lens.id)
    }
    
    func isFavorite(lens: Lens) async -> Bool {
        await userPreferencesRepository.isFavorite(lensId: lens.id)
    }
}

final class ComparisonUseCase: ComparisonUseCaseProtocol {
    private let userPreferencesRepository: UserPreferencesRepositoryProtocol
    private let lensRepository: LensRepositoryProtocol
    private let maxComparisonItems = 4
    
    init(
        userPreferencesRepository: UserPreferencesRepositoryProtocol,
        lensRepository: LensRepositoryProtocol
    ) {
        self.userPreferencesRepository = userPreferencesRepository
        self.lensRepository = lensRepository
    }
    
    func getComparisonLenses() async -> [Lens] {
        let comparisonIds = await userPreferencesRepository.getComparisonSet()
        let allLenses = (try? await lensRepository.fetchAllLenses()) ?? []
        return allLenses.filter { comparisonIds.contains($0.id) }
    }
    
    func addToComparison(lens: Lens) async throws {
        let currentSet = await userPreferencesRepository.getComparisonSet()
        guard currentSet.count < maxComparisonItems else {
            throw DomainError.maxComparisonItemsReached
        }
        try await userPreferencesRepository.addToComparison(lensId: lens.id)
    }
    
    func removeFromComparison(lens: Lens) async throws {
        await userPreferencesRepository.removeFromComparison(lensId: lens.id)
    }
    
    func clearComparison() async throws {
        await userPreferencesRepository.clearComparison()
    }
    
    func canAddToComparison() async -> Bool {
        let currentSet = await userPreferencesRepository.getComparisonSet()
        return currentSet.count < maxComparisonItems
    }
}

final class CompatibilityUseCase: CompatibilityUseCaseProtocol {
    private let cameraRepository: CameraRepositoryProtocol
    private let lensRepository: LensRepositoryProtocol
    
    init(
        cameraRepository: CameraRepositoryProtocol,
        lensRepository: LensRepositoryProtocol
    ) {
        self.cameraRepository = cameraRepository
        self.lensRepository = lensRepository
    }
    
    func checkCompatibility(lens: Lens, camera: Camera) async -> CompatibilityResult {
        let isCompatible = camera.isCompatible(with: lens)
        
        var notes: [String] = []
        if !isCompatible {
            notes.append("Format mismatch: Lens format '\(lens.format)' may not be fully compatible with camera sensor")
        }
        
        return CompatibilityResult(
            isCompatible: isCompatible,
            compatibility: isCompatible ? .full : .partial,
            notes: notes
        )
    }
    
    func getRecommendedCameras(for lens: Lens) async throws -> [Camera] {
        let allCameras = try await cameraRepository.fetchAllCameras()
        return allCameras.filter { camera in
            camera.isCompatible(with: lens)
        }.sorted { $0.displayName < $1.displayName }
    }
    
    func getCompatibleLenses(for camera: Camera) async throws -> [Lens] {
        let allLenses = try await lensRepository.fetchAllLenses()
        return allLenses.filter { lens in
            camera.isCompatible(with: lens)
        }.sorted { $0.displayName < $1.displayName }
    }
}

final class RentalUseCase: RentalUseCaseProtocol {
    private let rentalRepository: RentalRepositoryProtocol
    
    init(rentalRepository: RentalRepositoryProtocol) {
        self.rentalRepository = rentalRepository
    }
    
    func getAllRentals() async throws -> [Rental] {
        try await rentalRepository.fetchAllRentals()
    }
    
    func getLensesForRental(rentalId: String) async throws -> [Lens] {
        try await rentalRepository.fetchLensesForRental(rentalId: rentalId)
    }
    
    func getRentalsForLens(lensId: String) async throws -> [Rental] {
        try await rentalRepository.fetchRentalsForLens(lensId: lensId)
    }
}

// MARK: - Supporting Types

struct LensGroup: Identifiable {
    let id = UUID()
    let manufacturer: String
    let series: [LensSeries]
}

struct LensSeries: Identifiable {
    let id = UUID()
    let name: String
    let lenses: [Lens]
}

struct CompatibilityResult {
    let isCompatible: Bool
    let compatibility: CompatibilityLevel
    let notes: [String]
}

enum CompatibilityLevel {
    case full
    case partial
    case none
    
    var displayName: String {
        switch self {
        case .full: return "Fully Compatible"
        case .partial: return "Partially Compatible"
        case .none: return "Not Compatible"
        }
    }
}

// MARK: - Extensions

private extension String {
    func normalizedForGrouping() -> String {
        self.lowercased()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: "series", with: "", options: .caseInsensitive)
            .replacingOccurrences(of: "edition", with: "", options: .caseInsensitive)
    }
}