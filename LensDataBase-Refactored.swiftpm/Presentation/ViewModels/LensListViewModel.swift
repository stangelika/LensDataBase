import Foundation
import Observation

// MARK: - Application State

@Observable
final class AppState {
    var selectedTab: AppTab = .lenses
    var isLoading = false
    var errorMessage: String?
    var showingError = false
    
    func setError(_ error: Error) {
        errorMessage = error.localizedDescription
        showingError = true
    }
    
    func clearError() {
        errorMessage = nil
        showingError = false
    }
}

enum AppTab: CaseIterable {
    case lenses
    case favorites
    case comparison
    case rentals
    
    var title: String {
        switch self {
        case .lenses: return "Lenses"
        case .favorites: return "Favorites"
        case .comparison: return "Compare"
        case .rentals: return "Rentals"
        }
    }
    
    var systemImage: String {
        switch self {
        case .lenses: return "camera.fill"
        case .favorites: return "heart.fill"
        case .comparison: return "rectangle.split.3x1"
        case .rentals: return "building.2.fill"
        }
    }
}

// MARK: - Lens List View Model

@Observable
final class LensListViewModel {
    private let lensUseCase: LensUseCaseProtocol
    private let favoritesUseCase: FavoritesUseCaseProtocol
    private let comparisonUseCase: ComparisonUseCaseProtocol
    
    var lenses: [Lens] = []
    var groupedLenses: [LensGroup] = []
    var isLoading = false
    var errorMessage: String?
    var showingError = false
    
    // Filter state
    var searchText = ""
    var selectedFormat = ""
    var selectedFocalCategory: FocalLengthCategory = .all
    var selectedManufacturer = ""
    var showOnlyRentable = false
    var groupByManufacturer = true
    
    // Available filter options
    var availableFormats: [String] = []
    var availableManufacturers: [String] = []
    
    init(
        lensUseCase: LensUseCaseProtocol,
        favoritesUseCase: FavoritesUseCaseProtocol,
        comparisonUseCase: ComparisonUseCaseProtocol
    ) {
        self.lensUseCase = lensUseCase
        self.favoritesUseCase = favoritesUseCase
        self.comparisonUseCase = comparisonUseCase
    }
    
    @MainActor
    func loadLenses() async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            lenses = try await lensUseCase.getAllLenses()
            updateAvailableFilters()
            await applyFilters()
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
        
        isLoading = false
    }
    
    @MainActor
    func applyFilters() async {
        let criteria = LensFilterCriteria(
            format: selectedFormat.isEmpty ? nil : selectedFormat,
            focalLengthCategory: selectedFocalCategory == .all ? nil : selectedFocalCategory,
            manufacturer: selectedManufacturer.isEmpty ? nil : selectedManufacturer,
            searchQuery: searchText.isEmpty ? nil : searchText,
            onlyRentable: showOnlyRentable
        )
        
        do {
            let filteredLenses = try await lensUseCase.filterLenses(criteria: criteria)
            
            if groupByManufacturer {
                groupedLenses = lensUseCase.groupLensesByManufacturer(filteredLenses)
            } else {
                // Create flat structure for ungrouped view
                groupedLenses = [LensGroup(
                    manufacturer: "All Lenses",
                    series: [LensSeries(
                        name: "All",
                        lenses: filteredLenses.sorted { $0.displayName < $1.displayName }
                    )]
                )]
            }
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
    
    @MainActor
    func toggleFavorite(_ lens: Lens) async {
        do {
            try await favoritesUseCase.toggleFavorite(lens: lens)
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
    
    @MainActor
    func isFavorite(_ lens: Lens) async -> Bool {
        await favoritesUseCase.isFavorite(lens: lens)
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
    
    private func updateAvailableFilters() {
        availableFormats = Array(Set(lenses.map { $0.format })).sorted()
        availableManufacturers = Array(Set(lenses.map { $0.manufacturer })).sorted()
    }
    
    func clearError() {
        errorMessage = nil
        showingError = false
    }
}