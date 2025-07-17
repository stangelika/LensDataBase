import XCTest
import Combine
@testable import LensDataBase

final class DataManagerTests: XCTestCase {
    
    var dataManager: DataManager!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        dataManager = DataManager()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        dataManager = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertNil(dataManager.appData)
        XCTAssertEqual(dataManager.loadingState, .idle)
        XCTAssertTrue(dataManager.availableLenses.isEmpty)
        XCTAssertTrue(dataManager.cameras.isEmpty)
        XCTAssertTrue(dataManager.formats.isEmpty)
        XCTAssertEqual(dataManager.activeTab, .allLenses)
        XCTAssertEqual(dataManager.selectedRentalId, "")
        XCTAssertTrue(dataManager.favoriteLenses.isEmpty)
    }
    
    func testFavoriteManagement() {
        // Create test lens
        let testLens = Lens(
            id: "test-lens-1",
            display_name: "Test Lens",
            manufacturer: "Test",
            lens_name: "Test Series",
            format: "FF",
            focal_length: "50mm",
            aperture: "f/1.4",
            close_focus_in: "12\"",
            close_focus_cm: "30cm",
            image_circle: "43.3mm",
            length: "85mm",
            front_diameter: "77mm",
            squeeze_factor: nil
        )
        
        // Initially not favorite
        XCTAssertFalse(dataManager.isFavorite(lens: testLens))
        
        // Add to favorites
        dataManager.toggleFavorite(lens: testLens)
        XCTAssertTrue(dataManager.isFavorite(lens: testLens))
        XCTAssertTrue(dataManager.favoriteLenses.contains("test-lens-1"))
        
        // Remove from favorites
        dataManager.toggleFavorite(lens: testLens)
        XCTAssertFalse(dataManager.isFavorite(lens: testLens))
        XCTAssertFalse(dataManager.favoriteLenses.contains("test-lens-1"))
    }
    
    func testLensGrouping() {
        // Create test app data
        let testLenses = [
            Lens(
                id: "canon-1", display_name: "Canon EF 50mm f/1.4", manufacturer: "Canon",
                lens_name: "EF 50mm f/1.4", format: "FF", focal_length: "50mm",
                aperture: "f/1.4", close_focus_in: "18\"", close_focus_cm: "45cm",
                image_circle: "43.3mm", length: "73.8mm", front_diameter: "73.8mm",
                squeeze_factor: nil
            ),
            Lens(
                id: "canon-2", display_name: "Canon EF 85mm f/1.8", manufacturer: "Canon",
                lens_name: "EF 85mm f/1.8", format: "FF", focal_length: "85mm",
                aperture: "f/1.8", close_focus_in: "33\"", close_focus_cm: "85cm",
                image_circle: "43.3mm", length: "71.5mm", front_diameter: "58mm",
                squeeze_factor: nil
            ),
            Lens(
                id: "nikon-1", display_name: "Nikon AF-S 50mm f/1.4G", manufacturer: "Nikon",
                lens_name: "AF-S 50mm f/1.4G", format: "FF", focal_length: "50mm",
                aperture: "f/1.4", close_focus_in: "18\"", close_focus_cm: "45cm",
                image_circle: "43.3mm", length: "73.5mm", front_diameter: "73.5mm",
                squeeze_factor: nil
            )
        ]
        
        let testAppData = AppData(
            last_updated: "2024-01-01",
            rentals: [],
            lenses: testLenses,
            inventory: ["rental-1": [
                InventoryItem(lens_id: "canon-1"),
                InventoryItem(lens_id: "canon-2"),
                InventoryItem(lens_id: "nikon-1")
            ]]
        )
        
        dataManager.appData = testAppData
        dataManager.availableLenses = testLenses
        
        let groups = dataManager.groupLenses()
        
        XCTAssertEqual(groups.count, 2) // Canon and Nikon
        
        let canonGroup = groups.first { $0.manufacturer == "Canon" }
        let nikonGroup = groups.first { $0.manufacturer == "Nikon" }
        
        XCTAssertNotNil(canonGroup)
        XCTAssertNotNil(nikonGroup)
        XCTAssertEqual(canonGroup?.series.count, 2) // Two different Canon lenses
        XCTAssertEqual(nikonGroup?.series.count, 1) // One Nikon lens
    }
    
    func testLensDetailsRetrieval() {
        let testLens = Lens(
            id: "test-lens-1",
            display_name: "Test Lens",
            manufacturer: "Test",
            lens_name: "Test Series",
            format: "FF",
            focal_length: "50mm",
            aperture: "f/1.4",
            close_focus_in: "12\"",
            close_focus_cm: "30cm",
            image_circle: "43.3mm",
            length: "85mm",
            front_diameter: "77mm",
            squeeze_factor: nil
        )
        
        let testAppData = AppData(
            last_updated: "2024-01-01",
            rentals: [],
            lenses: [testLens],
            inventory: [:]
        )
        
        dataManager.appData = testAppData
        
        // Test finding existing lens
        let foundLens = dataManager.lensDetails(for: "test-lens-1")
        XCTAssertNotNil(foundLens)
        XCTAssertEqual(foundLens?.id, "test-lens-1")
        
        // Test non-existing lens
        let notFoundLens = dataManager.lensDetails(for: "non-existing")
        XCTAssertNil(notFoundLens)
    }
    
    func testDataLoadingStates() {
        // Initial state
        XCTAssertEqual(dataManager.loadingState, .idle)
        
        // Test loading state transition
        dataManager.loadingState = .loading
        XCTAssertEqual(dataManager.loadingState, .loading)
        
        // Test loaded state
        dataManager.loadingState = .loaded
        XCTAssertEqual(dataManager.loadingState, .loaded)
        
        // Test error state
        dataManager.loadingState = .error("Test error")
        if case .error(let message) = dataManager.loadingState {
            XCTAssertEqual(message, "Test error")
        } else {
            XCTFail("Expected error state")
        }
    }
    
    func testRentalsForLens() {
        let testRental = Rental(
            id: "rental-1",
            name: "Test Rental",
            address: "123 Test St",
            phone: "555-1234",
            website: "test.com"
        )
        
        let testLens = Lens(
            id: "test-lens-1",
            display_name: "Test Lens",
            manufacturer: "Test",
            lens_name: "Test Series",
            format: "FF",
            focal_length: "50mm",
            aperture: "f/1.4",
            close_focus_in: "12\"",
            close_focus_cm: "30cm",
            image_circle: "43.3mm",
            length: "85mm",
            front_diameter: "77mm",
            squeeze_factor: nil
        )
        
        let testAppData = AppData(
            last_updated: "2024-01-01",
            rentals: [testRental],
            lenses: [testLens],
            inventory: ["rental-1": [InventoryItem(lens_id: "test-lens-1")]]
        )
        
        dataManager.appData = testAppData
        
        let rentals = dataManager.rentalsForLens("test-lens-1")
        XCTAssertEqual(rentals.count, 1)
        XCTAssertEqual(rentals.first?.id, "rental-1")
        XCTAssertEqual(rentals.first?.name, "Test Rental")
        
        // Test lens not in inventory
        let noRentals = dataManager.rentalsForLens("non-existing-lens")
        XCTAssertTrue(noRentals.isEmpty)
    }
}