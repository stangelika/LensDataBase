import Foundation
import Observation

// MARK: - Favorites View Model

@Observable
final class FavoritesViewModel {
    private let favoritesUseCase: FavoritesUseCaseProtocol
    private let comparisonUseCase: ComparisonUseCaseProtocol
    
    var favorites: [Lens] = []
    var isLoading = false
    var errorMessage: String?
    var showingError = false
    
    init(
        favoritesUseCase: FavoritesUseCaseProtocol,
        comparisonUseCase: ComparisonUseCaseProtocol
    ) {
        self.favoritesUseCase = favoritesUseCase
        self.comparisonUseCase = comparisonUseCase
    }
    
    @MainActor
    func loadFavorites() async {
        isLoading = true
        errorMessage = nil
        
        favorites = await favoritesUseCase.getFavorites()
        
        isLoading = false
    }
    
    @MainActor
    func removeFavorite(_ lens: Lens) async {
        do {
            try await favoritesUseCase.toggleFavorite(lens: lens)
            await loadFavorites() // Refresh the list
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
    
    @MainActor
    func toggleComparison(_ lens: Lens) async {
        do {
            let isInComparison = await isInComparison(lens)
            if isInComparison {
                try await comparisonUseCase.removeFromComparison(lens: lens)
            } else {
                try await comparisonUseCase.addToComparison(lens: lens)
            }
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
    
    @MainActor
    func isInComparison(_ lens: Lens) async -> Bool {
        let comparisonLenses = await comparisonUseCase.getComparisonLenses()
        return comparisonLenses.contains { $0.id == lens.id }
    }
    
    @MainActor
    func canAddToComparison() async -> Bool {
        await comparisonUseCase.canAddToComparison()
    }
    
    func clearError() {
        errorMessage = nil
        showingError = false
    }
}

// MARK: - Lens Detail View Model

@Observable
final class LensDetailViewModel {
    private let lensId: String
    private let lensUseCase: LensUseCaseProtocol
    private let favoritesUseCase: FavoritesUseCaseProtocol
    private let comparisonUseCase: ComparisonUseCaseProtocol
    private let compatibilityUseCase: CompatibilityUseCaseProtocol
    private let rentalUseCase: RentalUseCaseProtocol
    
    var lens: Lens?
    var compatibleCameras: [Camera] = []
    var availableRentals: [Rental] = []
    var isLoading = false
    var errorMessage: String?
    var showingError = false
    
    var isFavorite = false
    var isInComparison = false
    var canAddToComparison = true
    
    init(
        lensId: String,
        lensUseCase: LensUseCaseProtocol,
        favoritesUseCase: FavoritesUseCaseProtocol,
        comparisonUseCase: ComparisonUseCaseProtocol,
        compatibilityUseCase: CompatibilityUseCaseProtocol,
        rentalUseCase: RentalUseCaseProtocol
    ) {
        self.lensId = lensId
        self.lensUseCase = lensUseCase
        self.favoritesUseCase = favoritesUseCase
        self.comparisonUseCase = comparisonUseCase
        self.compatibilityUseCase = compatibilityUseCase
        self.rentalUseCase = rentalUseCase
    }
    
    @MainActor
    func loadLensDetails() async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            lens = try await lensUseCase.getLensDetails(id: lensId)
            
            if let lens = lens {
                // Load related data
                async let compatibleCamerasTask = compatibilityUseCase.getRecommendedCameras(for: lens)
                async let availableRentalsTask = rentalUseCase.getRentalsForLens(lensId: lens.id)
                async let isFavoriteTask = favoritesUseCase.isFavorite(lens: lens)
                async let isInComparisonTask = isInComparison(lens)
                async let canAddToComparisonTask = comparisonUseCase.canAddToComparison()
                
                compatibleCameras = try await compatibleCamerasTask
                availableRentals = try await availableRentalsTask
                isFavorite = await isFavoriteTask
                isInComparison = await isInComparisonTask
                canAddToComparison = await canAddToComparisonTask
            }
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
        
        isLoading = false
    }
    
    @MainActor
    func toggleFavorite() async {
        guard let lens = lens else { return }
        
        do {
            try await favoritesUseCase.toggleFavorite(lens: lens)
            isFavorite = await favoritesUseCase.isFavorite(lens: lens)
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
    
    @MainActor
    func toggleComparison() async {
        guard let lens = lens else { return }
        
        do {
            if isInComparison {
                try await comparisonUseCase.removeFromComparison(lens: lens)
            } else {
                try await comparisonUseCase.addToComparison(lens: lens)
            }
            
            isInComparison = await self.isInComparison(lens)
            canAddToComparison = await comparisonUseCase.canAddToComparison()
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
    
    private func isInComparison(_ lens: Lens) async -> Bool {
        let comparisonLenses = await comparisonUseCase.getComparisonLenses()
        return comparisonLenses.contains { $0.id == lens.id }
    }
    
    func clearError() {
        errorMessage = nil
        showingError = false
    }
}

// MARK: - Comparison View Model

@Observable
final class ComparisonViewModel {
    private let comparisonUseCase: ComparisonUseCaseProtocol
    private let lensUseCase: LensUseCaseProtocol
    
    var comparisonLenses: [Lens] = []
    var isLoading = false
    var errorMessage: String?
    var showingError = false
    
    init(
        comparisonUseCase: ComparisonUseCaseProtocol,
        lensUseCase: LensUseCaseProtocol
    ) {
        self.comparisonUseCase = comparisonUseCase
        self.lensUseCase = lensUseCase
    }
    
    @MainActor
    func loadComparison() async {
        isLoading = true
        errorMessage = nil
        
        comparisonLenses = await comparisonUseCase.getComparisonLenses()
        
        isLoading = false
    }
    
    @MainActor
    func removeFromComparison(_ lens: Lens) async {
        do {
            try await comparisonUseCase.removeFromComparison(lens: lens)
            await loadComparison() // Refresh the list
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
    
    @MainActor
    func clearComparison() async {
        do {
            try await comparisonUseCase.clearComparison()
            await loadComparison() // Refresh the list
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
    
    func clearError() {
        errorMessage = nil
        showingError = false
    }
}

// MARK: - Rental View Model

@Observable
final class RentalViewModel {
    private let rentalUseCase: RentalUseCaseProtocol
    private let lensUseCase: LensUseCaseProtocol
    
    var rentals: [Rental] = []
    var selectedRental: Rental?
    var lensesForSelectedRental: [Lens] = []
    var isLoading = false
    var errorMessage: String?
    var showingError = false
    
    init(
        rentalUseCase: RentalUseCaseProtocol,
        lensUseCase: LensUseCaseProtocol
    ) {
        self.rentalUseCase = rentalUseCase
        self.lensUseCase = lensUseCase
    }
    
    @MainActor
    func loadRentals() async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            rentals = try await rentalUseCase.getAllRentals()
            
            // Select first rental by default
            if selectedRental == nil, let firstRental = rentals.first {
                await selectRental(firstRental)
            }
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
        
        isLoading = false
    }
    
    @MainActor
    func selectRental(_ rental: Rental) async {
        selectedRental = rental
        
        do {
            lensesForSelectedRental = try await rentalUseCase.getLensesForRental(rentalId: rental.id)
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
    
    func clearError() {
        errorMessage = nil
        showingError = false
    }
}