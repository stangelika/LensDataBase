import Foundation

// MARK: - Dependency Container

final class DependencyContainer {
    static let shared = DependencyContainer()
    
    private init() {}
    
    // MARK: - Services
    
    lazy var networkService: NetworkServiceProtocol = {
        CachedNetworkService()
    }()
    
    lazy var cacheService: CacheServiceProtocol = {
        CacheService()
    }()
    
    // MARK: - Repositories
    
    lazy var lensRepository: LensRepositoryProtocol = {
        LensRepository(networkService: networkService)
    }()
    
    lazy var cameraRepository: CameraRepositoryProtocol = {
        CameraRepository(networkService: networkService)
    }()
    
    lazy var rentalRepository: RentalRepositoryProtocol = {
        RentalRepository(networkService: networkService, lensRepository: lensRepository)
    }()
    
    lazy var userPreferencesRepository: UserPreferencesRepositoryProtocol = {
        UserPreferencesRepository()
    }()
    
    // MARK: - Use Cases
    
    lazy var lensUseCase: LensUseCaseProtocol = {
        LensUseCase(lensRepository: lensRepository)
    }()
    
    lazy var favoritesUseCase: FavoritesUseCaseProtocol = {
        FavoritesUseCase(
            userPreferencesRepository: userPreferencesRepository,
            lensRepository: lensRepository
        )
    }()
    
    lazy var comparisonUseCase: ComparisonUseCaseProtocol = {
        ComparisonUseCase(
            userPreferencesRepository: userPreferencesRepository,
            lensRepository: lensRepository
        )
    }()
    
    lazy var compatibilityUseCase: CompatibilityUseCaseProtocol = {
        CompatibilityUseCase(
            cameraRepository: cameraRepository,
            lensRepository: lensRepository
        )
    }()
    
    lazy var rentalUseCase: RentalUseCaseProtocol = {
        RentalUseCase(rentalRepository: rentalRepository)
    }()
    
    // MARK: - Factory Methods
    
    func makeLensListViewModel() -> LensListViewModel {
        LensListViewModel(
            lensUseCase: lensUseCase,
            favoritesUseCase: favoritesUseCase,
            comparisonUseCase: comparisonUseCase
        )
    }
    
    func makeFavoritesViewModel() -> FavoritesViewModel {
        FavoritesViewModel(
            favoritesUseCase: favoritesUseCase,
            comparisonUseCase: comparisonUseCase
        )
    }
    
    func makeLensDetailViewModel(lensId: String) -> LensDetailViewModel {
        LensDetailViewModel(
            lensId: lensId,
            lensUseCase: lensUseCase,
            favoritesUseCase: favoritesUseCase,
            comparisonUseCase: comparisonUseCase,
            compatibilityUseCase: compatibilityUseCase,
            rentalUseCase: rentalUseCase
        )
    }
    
    func makeComparisonViewModel() -> ComparisonViewModel {
        ComparisonViewModel(
            comparisonUseCase: comparisonUseCase,
            lensUseCase: lensUseCase
        )
    }
    
    func makeRentalViewModel() -> RentalViewModel {
        RentalViewModel(
            rentalUseCase: rentalUseCase,
            lensUseCase: lensUseCase
        )
    }
}

// MARK: - Dependency Injection Protocol

protocol Injectable {
    static func resolve() -> Self
}

extension DependencyContainer {
    func resolve<T>(_ type: T.Type) -> T {
        switch type {
        // Services
        case is NetworkServiceProtocol.Type:
            return networkService as! T
        case is CacheServiceProtocol.Type:
            return cacheService as! T
            
        // Repositories
        case is LensRepositoryProtocol.Type:
            return lensRepository as! T
        case is CameraRepositoryProtocol.Type:
            return cameraRepository as! T
        case is RentalRepositoryProtocol.Type:
            return rentalRepository as! T
        case is UserPreferencesRepositoryProtocol.Type:
            return userPreferencesRepository as! T
            
        // Use Cases
        case is LensUseCaseProtocol.Type:
            return lensUseCase as! T
        case is FavoritesUseCaseProtocol.Type:
            return favoritesUseCase as! T
        case is ComparisonUseCaseProtocol.Type:
            return comparisonUseCase as! T
        case is CompatibilityUseCaseProtocol.Type:
            return compatibilityUseCase as! T
        case is RentalUseCaseProtocol.Type:
            return rentalUseCase as! T
            
        default:
            fatalError("Type \(type) is not registered in DependencyContainer")
        }
    }
}

// MARK: - Testing Container

#if DEBUG
final class TestDependencyContainer: DependencyContainer {
    override init() {
        super.init()
    }
    
    // Override with mock implementations for testing
    override lazy var networkService: NetworkServiceProtocol = {
        MockNetworkService()
    }()
}

// MARK: - Mock Implementations for Testing

class MockNetworkService: NetworkServiceProtocol {
    func fetchLensData() async throws -> APIDatabase {
        // Return mock data for testing
        APIDatabase(
            rentals: [],
            lenses: [],
            inventory: []
        )
    }
    
    func fetchCameraData() async throws -> APICameraResponse {
        // Return mock data for testing
        APICameraResponse(
            camera: [],
            formats: []
        )
    }
}
#endif