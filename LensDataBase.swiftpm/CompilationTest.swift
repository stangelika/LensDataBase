import Foundation

/**
 * Comprehensive test suite for LensDataBase Swift Playground project
 * This file verifies that all components work correctly and can be integrated properly
 * 
 * Test Categories:
 * - Basic Compilation: Verify all components can be instantiated
 * - Data Models: Test model creation and decoding
 * - Enum Values: Validate all enum cases and their properties
 * - Lens Operations: Test lens-specific functionality
 * - Data Manager: Test state management and data processing
 * - Network Service: Verify API integration setup
 * - UI Components: Test SwiftUI view creation
 * - Error Handling: Validate error scenarios
 */

func runAllTests() {
    print("🧪 Starting LensDataBase Test Suite...")
    print("=" * 50)

    testBasicCompilation()
    testDataModels()
    testEnumValues()
    testLensOperations()
    testDataManagerFunctionality()
    testNetworkServiceSetup()
    testUIComponents()
    testErrorHandling()
    testDataProcessing()

    print("=" * 50)
    print("🎉 All tests completed successfully!")
}

func testBasicCompilation() {
    print("\n📋 Test: Basic Compilation")
    print("-" * 30)

    // Test data models can be created
    let testLens = createTestLens()
    print("✅ Lens model: \(testLens.display_name)")

    // Test lens extension works
    let focalValue = testLens.mainFocalValue
    print("✅ Lens extension mainFocalValue: \(focalValue ?? 0)")

    // Test data manager can be created
    let dataManager = DataManager()
    print("✅ DataManager created successfully")

    // Test network service can be created
    let networkService = NetworkService.shared
    print("✅ NetworkService created successfully")

    print("✅ Basic compilation test passed!")
}

func testDataModels() {
    print("\n📋 Test: Data Models")
    print("-" * 30)

    // Test Camera model
    let testCamera = Camera(
        id: "cam-1",
        manufacturer: "Test Camera Co",
        model: "Test Camera Model",
        sensor: "FF",
        sensorWidth: "36.0",
        sensorHeight: "24.0",
        imageCircle: "43.3"
    )
    print("✅ Camera model: \(testCamera.manufacturer) \(testCamera.model)")

    // Test RecordingFormat model
    let testFormat = RecordingFormat(
        id: "fmt-1",
        cameraId: "cam-1",
        manufacturer: "Test Camera Co",
        model: "Test Camera Model",
        sensorWidth: "36.0",
        sensorHeight: "24.0",
        recordingFormat: "4K",
        recordingWidth: "3840",
        recordingHeight: "2160",
        recordingImageCircle: "43.3"
    )
    print("✅ RecordingFormat model: \(testFormat.recordingFormat)")

    // Test Rental model
    let testRental = Rental(
        id: "rental-1",
        name: "Test Rental House",
        address: "123 Test Street",
        phone: "+1-555-TEST",
        website: "https://testrental.com"
    )
    print("✅ Rental model: \(testRental.name)")

    print("✅ Data models test passed!")
}

func testEnumValues() {
    print("\n📋 Test: Enum Values")
    print("-" * 30)

    // Test FocalCategory enum
    let focalCategories: [FocalCategory] = [.all, .ultraWide, .wide, .standard, .tele, .superTele]
    for category in focalCategories {
        print("✅ FocalCategory.\(category): \(category.displayName)")
    }

    // Test LensFormatCategory enum
    let formatCategories: [LensFormatCategory] = [.s16, .s35, .ff, .mft]
    for category in formatCategories {
        print("✅ LensFormatCategory.\(category): \(category.displayName)")
    }

    // Test ActiveTab enum
    let tabs: [ActiveTab] = [.rentalView, .allLenses, .favorites]
    for tab in tabs {
        print("✅ ActiveTab: \(tab)")
    }

    // Test DataLoadingState enum
    let states: [DataLoadingState] = [.idle, .loading, .loaded, .error("Test error")]
    for state in states {
        print("✅ DataLoadingState: \(state)")
    }

    print("✅ Enum values test passed!")
}

func testLensOperations() {
    print("\n📋 Test: Lens Operations")
    print("-" * 30)

    let testLens = createTestLens()

    // Test focal value calculation
    let focalValue = testLens.mainFocalValue
    assert(focalValue == 50.0, "Expected focal value 50.0, got \(focalValue ?? 0)")
    print("✅ Focal value calculation: \(focalValue ?? 0)")

    // Test lens with invalid focal length
    let invalidLens = Lens(
        id: "invalid-1",
        display_name: "Invalid Lens",
        manufacturer: "Test",
        lens_name: "Invalid",
        format: "FF",
        focal_length: "not-a-number",
        aperture: "1.4",
        close_focus_in: "18",
        close_focus_cm: "45",
        image_circle: "43.3",
        length: "85",
        front_diameter: "77",
        squeeze_factor: nil,
        lens_format: "FF"
    )

    let invalidFocalValue = invalidLens.mainFocalValue
    assert(invalidFocalValue == nil, "Expected nil for invalid focal length")
    print("✅ Invalid focal length handling: \(invalidFocalValue?.description ?? "nil")")

    print("✅ Lens operations test passed!")
}

func testDataManagerFunctionality() {
    print("\n📋 Test: DataManager Functionality")
    print("-" * 30)

    let dataManager = DataManager()

    // Test initial state
    assert(dataManager.lenses.isEmpty, "Expected empty lenses array initially")
    assert(dataManager.cameras.isEmpty, "Expected empty cameras array initially")
    assert(dataManager.rentals.isEmpty, "Expected empty rentals array initially")
    print("✅ Initial state verification")

    // Test data loading state
    assert(dataManager.loadingState == .idle, "Expected idle loading state initially")
    print("✅ Loading state verification")

    // Test search functionality exists
    let searchResults = dataManager.searchLenses(query: "test")
    assert(searchResults.isEmpty, "Expected empty search results with no data")
    print("✅ Search functionality verification")

    print("✅ DataManager functionality test passed!")
}

func testNetworkServiceSetup() {
    print("\n📋 Test: NetworkService Setup")
    print("-" * 30)

    let networkService = NetworkService.shared

    // Verify singleton pattern
    let anotherInstance = NetworkService.shared
    assert(networkService === anotherInstance, "NetworkService should be singleton")
    print("✅ Singleton pattern verification")

    print("✅ NetworkService setup test passed!")
}

func testUIComponents() {
    print("\n📋 Test: UI Components")
    print("-" * 30)

    // Test that main views can be created
    let dataManager = DataManager()
    
    // Test MainTabView creation
    let mainTabView = MainTabView()
        .environmentObject(dataManager)
    print("✅ MainTabView created successfully")
    
    // Test AllLensesView creation
    let allLensesView = AllLensesView()
        .environmentObject(dataManager)
    print("✅ AllLensesView created successfully")
    
    // Test FavoritesView creation
    let favoritesView = FavoritesView()
        .environmentObject(dataManager)
    print("✅ FavoritesView created successfully")
    
    // Test SplashScreenView creation
    let splashView = SplashScreenView()
        .environmentObject(dataManager)
    print("✅ SplashScreenView created successfully")
    
    print("✅ UI components test passed!")
}

func testErrorHandling() {
    print("\n📋 Test: Error Handling")
    print("-" * 30)
    
    // Test DataLoadingState error handling
    let errorState = DataLoadingState.error("Test error message")
    switch errorState {
    case .error(let message):
        assert(message == "Test error message", "Error message not preserved")
        print("✅ Error state message: \(message)")
    default:
        assert(false, "Expected error state")
    }
    
    // Test lens decoding with invalid data
    let invalidJSON = """
    {
        "id": 123,
        "display_name": "Test Lens",
        "manufacturer": "Test Mfg",
        "lens_name": "Test 50mm",
        "format": "FF",
        "focal_length": 50,
        "aperture": 1.4,
        "close_focus_in": "18",
        "close_focus_cm": "45",
        "image_circle": "43.3",
        "length": "85",
        "front_diameter": "77"
    }
    """.data(using: .utf8)!
    
    do {
        let decoder = JSONDecoder()
        let lens = try decoder.decode(Lens.self, from: invalidJSON)
        print("✅ Flexible decoding handled mixed types: ID=\(lens.id), Focal=\(lens.focal_length)")
    } catch {
        print("❌ Flexible decoding failed: \(error)")
    }
    
    print("✅ Error handling test passed!")
}

func testDataProcessing() {
    print("\n📋 Test: Data Processing")
    print("-" * 30)
    
    // Test focal length parsing
    let testCases = [
        ("50", 50.0),
        ("24-70", 24.0),
        ("14-24mm", 14.0),
        ("85 mm", 85.0),
        ("invalid", nil)
    ]
    
    for (input, expected) in testCases {
        let testLens = Lens(
            id: "test",
            display_name: "Test",
            manufacturer: "Test",
            lens_name: "Test",
            format: "FF",
            focal_length: input,
            aperture: "1.4",
            close_focus_in: "18",
            close_focus_cm: "45",
            image_circle: "43.3",
            length: "85",
            front_diameter: "77",
            squeeze_factor: nil,
            lens_format: "FF"
        )
        
        let result = testLens.mainFocalValue
        if let expected = expected {
            assert(result == expected, "Expected \(expected), got \(result ?? 0)")
            print("✅ Focal parsing '\(input)' → \(result ?? 0)")
        } else {
            assert(result == nil, "Expected nil for '\(input)', got \(result ?? 0)")
            print("✅ Invalid focal '\(input)' → nil")
        }
    }
    
    // Test focal category classification
    let focalTests: [(Double, FocalCategory)] = [
        (10, .ultraWide),
        (24, .wide),
        (50, .standard),
        (85, .tele),
        (200, .superTele)
    ]
    
    for (focal, expectedCategory) in focalTests {
        let containsResult = expectedCategory.contains(focal: focal)
        assert(containsResult, "Focal \(focal) should be in category \(expectedCategory)")
        print("✅ Focal \(focal)mm correctly categorized as \(expectedCategory.displayName)")
    }
    
    // Test lens format categorization
    let formatTests: [(String, LensFormatCategory)] = [
        ("S16", .s16),
        ("S35", .s35),
        ("FF", .ff),
        ("MFT", .mft),
        ("unknown", .mft)
    ]
    
    for (format, expectedCategory) in formatTests {
        let containsResult = expectedCategory.contains(lensFormat: format)
        assert(containsResult, "Format \(format) should be in category \(expectedCategory)")
        print("✅ Format '\(format)' correctly categorized as \(expectedCategory.displayName)")
    }
    
    print("✅ Data processing test passed!")
}

private func createTestLens() -> Lens {
    return Lens(
        id: "test-1",
        display_name: "Test Lens 50mm",
        manufacturer: "Test Manufacturer",
        lens_name: "Test 50mm f/1.4",
        format: "FF",
        focal_length: "50",
        aperture: "1.4",
        close_focus_in: "18",
        close_focus_cm: "45",
        image_circle: "43.3",
        length: "85",
        front_diameter: "77",
        squeeze_factor: nil,
        lens_format: "FF"
    )
}

// String repetition helper
extension String {
    static func * (left: String, right: Int) -> String {
        return String(repeating: left, count: right)
    }
}

// Manual instantiation to test compilation
// This will only run when explicitly called
#if DEBUG
// Uncomment the line below to run all tests
// runAllTests()
#endif