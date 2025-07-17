import XCTest
import Combine
@testable import LensDataBase

final class DataManagerTests: XCTestCase {
    
    private var dataManager: DataManager!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        dataManager = DataManager()
        cancellables = Set<AnyCancellable>()
        
        // Clear UserDefaults for testing
        UserDefaults.standard.removeObject(forKey: "favoriteLenses")
    }
    
    override func tearDown() {
        dataManager = nil
        cancellables = nil
        UserDefaults.standard.removeObject(forKey: "favoriteLenses")
        super.tearDown()
    }
    
    // MARK: - Favorites Tests
    
    func testInitialFavoritesEmpty() {
        XCTAssertTrue(dataManager.favoriteLenses.isEmpty)
    }
    
    func testToggleFavorite() {
        let lens = createTestLens()
        
        // Initially not favorite
        XCTAssertFalse(dataManager.isFavorite(lens: lens))
        
        // Toggle to favorite
        dataManager.toggleFavorite(lens: lens)
        XCTAssertTrue(dataManager.isFavorite(lens: lens))
        XCTAssertTrue(dataManager.favoriteLenses.contains(lens.id))
        
        // Toggle back to not favorite
        dataManager.toggleFavorite(lens: lens)
        XCTAssertFalse(dataManager.isFavorite(lens: lens))
        XCTAssertFalse(dataManager.favoriteLenses.contains(lens.id))
    }
    
    func testFavoritesPersistence() {
        let lens = createTestLens()
        
        // Add to favorites
        dataManager.toggleFavorite(lens: lens)
        XCTAssertTrue(dataManager.isFavorite(lens: lens))
        
        // Create new data manager instance
        let newDataManager = DataManager()
        
        // Favorites should be loaded from UserDefaults
        XCTAssertTrue(newDataManager.isFavorite(lens: lens))
        XCTAssertTrue(newDataManager.favoriteLenses.contains(lens.id))
    }
    
    func testMultipleFavorites() {
        let lens1 = createTestLens(id: "lens1")
        let lens2 = createTestLens(id: "lens2")
        let lens3 = createTestLens(id: "lens3")
        
        // Add multiple favorites
        dataManager.toggleFavorite(lens: lens1)
        dataManager.toggleFavorite(lens: lens2)
        dataManager.toggleFavorite(lens: lens3)
        
        XCTAssertEqual(dataManager.favoriteLenses.count, 3)
        XCTAssertTrue(dataManager.isFavorite(lens: lens1))
        XCTAssertTrue(dataManager.isFavorite(lens: lens2))
        XCTAssertTrue(dataManager.isFavorite(lens: lens3))
        
        // Remove one favorite
        dataManager.toggleFavorite(lens: lens2)
        XCTAssertEqual(dataManager.favoriteLenses.count, 2)
        XCTAssertTrue(dataManager.isFavorite(lens: lens1))
        XCTAssertFalse(dataManager.isFavorite(lens: lens2))
        XCTAssertTrue(dataManager.isFavorite(lens: lens3))
    }
    
    // MARK: - Data Loading State Tests
    
    func testInitialLoadingState() {
        XCTAssertEqual(dataManager.loadingState, .idle)
    }
    
    func testLoadingStateChanges() {
        let expectation = XCTestExpectation(description: "Loading state changes")
        var stateChanges: [DataLoadingState] = []
        
        dataManager.$loadingState
            .sink { state in
                stateChanges.append(state)
                if stateChanges.count >= 2 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Start loading
        dataManager.loadData()
        
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(stateChanges.first, .idle)
        XCTAssertEqual(stateChanges[1], .loading)
    }
    
    // MARK: - Active Tab Tests
    
    func testInitialActiveTab() {
        XCTAssertEqual(dataManager.activeTab, .allLenses)
    }
    
    func testActiveTabChanges() {
        dataManager.activeTab = .rentalView
        XCTAssertEqual(dataManager.activeTab, .rentalView)
        
        dataManager.activeTab = .favorites
        XCTAssertEqual(dataManager.activeTab, .favorites)
        
        dataManager.activeTab = .updateView
        XCTAssertEqual(dataManager.activeTab, .updateView)
    }
    
    // MARK: - Lens Grouping Tests
    
    func testGroupLensesEmpty() {
        let groups = dataManager.groupLenses()
        XCTAssertTrue(groups.isEmpty)
    }
    
    func testGroupLensesByManufacturer() {
        // Set up test data
        let cannonLens1 = createTestLens(id: "canon1", manufacturer: "Canon", lensName: "EF 50mm f/1.8")
        let cannonLens2 = createTestLens(id: "canon2", manufacturer: "Canon", lensName: "EF 85mm f/1.8")
        let sonyLens = createTestLens(id: "sony1", manufacturer: "Sony", lensName: "FE 50mm f/1.8")
        
        dataManager.availableLenses = [cannonLens1, cannonLens2, sonyLens]
        
        let groups = dataManager.groupLenses()
        
        XCTAssertEqual(groups.count, 2)
        
        let cannonGroup = groups.first { $0.manufacturer == "Canon" }
        let sonyGroup = groups.first { $0.manufacturer == "Sony" }
        
        XCTAssertNotNil(cannonGroup)
        XCTAssertNotNil(sonyGroup)
        XCTAssertEqual(cannonGroup?.series.count, 2)
        XCTAssertEqual(sonyGroup?.series.count, 1)
    }
    
    func testGroupLensesBySeries() {
        // Set up test data with same manufacturer but different series
        let lens1 = createTestLens(id: "lens1", manufacturer: "Canon", lensName: "EF 50mm f/1.8")
        let lens2 = createTestLens(id: "lens2", manufacturer: "Canon", lensName: "EF 50mm f/1.4")
        let lens3 = createTestLens(id: "lens3", manufacturer: "Canon", lensName: "EF 85mm f/1.8")
        
        dataManager.availableLenses = [lens1, lens2, lens3]
        
        let groups = dataManager.groupLenses()
        
        XCTAssertEqual(groups.count, 1)
        
        let cannonGroup = groups.first!
        XCTAssertEqual(cannonGroup.manufacturer, "Canon")
        XCTAssertEqual(cannonGroup.series.count, 2)
        
        let efSeries = cannonGroup.series.first { $0.name.contains("50mm") }
        XCTAssertNotNil(efSeries)
        XCTAssertEqual(efSeries?.lenses.count, 2)
    }
    
    // MARK: - Lens Details Tests
    
    func testLensDetailsFound() {
        let testLens = createTestLens()
        let appData = AppData(
            last_updated: "2024-01-01T00:00:00Z",
            rentals: [],
            lenses: [testLens],
            inventory: [:]
        )
        dataManager.appData = appData
        
        let foundLens = dataManager.lensDetails(for: testLens.id)
        
        XCTAssertNotNil(foundLens)
        XCTAssertEqual(foundLens?.id, testLens.id)
        XCTAssertEqual(foundLens?.manufacturer, testLens.manufacturer)
    }
    
    func testLensDetailsNotFound() {
        let testLens = createTestLens()
        let appData = AppData(
            last_updated: "2024-01-01T00:00:00Z",
            rentals: [],
            lenses: [testLens],
            inventory: [:]
        )
        dataManager.appData = appData
        
        let foundLens = dataManager.lensDetails(for: "nonexistent")
        
        XCTAssertNil(foundLens)
    }
    
    func testLensDetailsWithNoAppData() {
        let foundLens = dataManager.lensDetails(for: "test123")
        XCTAssertNil(foundLens)
    }
    
    // MARK: - Rental Tests
    
    func testRentalsForLens() {
        let testLens = createTestLens()
        let rental1 = Rental(
            id: "rental1",
            name: "Camera Rental Pro",
            address: "123 Main St",
            phone: "+1-555-123-4567",
            website: "https://example.com"
        )
        let rental2 = Rental(
            id: "rental2",
            name: "Lens Rental Co",
            address: "456 Oak Ave",
            phone: "+1-555-987-6543",
            website: "https://example2.com"
        )
        
        let appData = AppData(
            last_updated: "2024-01-01T00:00:00Z",
            rentals: [rental1, rental2],
            lenses: [testLens],
            inventory: [
                "rental1": [InventoryItem(lens_id: testLens.id)],
                "rental2": [InventoryItem(lens_id: testLens.id)]
            ]
        )
        dataManager.appData = appData
        
        let rentals = dataManager.rentalsForLens(testLens.id)
        
        XCTAssertEqual(rentals.count, 2)
        XCTAssertTrue(rentals.contains { $0.id == "rental1" })
        XCTAssertTrue(rentals.contains { $0.id == "rental2" })
    }
    
    func testRentalsForLensNotFound() {
        let testLens = createTestLens()
        let rental = Rental(
            id: "rental1",
            name: "Camera Rental Pro",
            address: "123 Main St",
            phone: "+1-555-123-4567",
            website: "https://example.com"
        )
        
        let appData = AppData(
            last_updated: "2024-01-01T00:00:00Z",
            rentals: [rental],
            lenses: [testLens],
            inventory: [
                "rental1": [InventoryItem(lens_id: "different_lens_id")]
            ]
        )
        dataManager.appData = appData
        
        let rentals = dataManager.rentalsForLens(testLens.id)
        
        XCTAssertTrue(rentals.isEmpty)
    }
    
    func testRentalsForLensWithNoAppData() {
        let rentals = dataManager.rentalsForLens("test123")
        XCTAssertTrue(rentals.isEmpty)
    }
    
    // MARK: - Helper Methods
    
    private func createTestLens(id: String = "test123", manufacturer: String = "Test Corp", lensName: String = "Test 50mm") -> Lens {
        return Lens(
            id: id,
            display_name: "Test Lens",
            manufacturer: manufacturer,
            lens_name: lensName,
            format: "Full Frame",
            focal_length: "50",
            aperture: "f/1.8",
            close_focus_in: "18",
            close_focus_cm: "45.7",
            image_circle: "43.3",
            length: "69",
            front_diameter: "67",
            squeeze_factor: nil
        )
    }
}

// MARK: - Test Helper Extensions

extension AppData {
    init(last_updated: String, rentals: [Rental], lenses: [Lens], inventory: [String: [InventoryItem]]) {
        self.last_updated = last_updated
        self.rentals = rentals
        self.lenses = lenses
        self.inventory = inventory
    }
}