import Foundation

/**
 * Comprehensive test suite for LensDataBase Swift Playground project
 * This file verifies that all components work correctly and can be integrated properly
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
    let focalCategories: [FocalCategory] = [.wide, .standard, .telephoto, .superTelephoto]
    for category in focalCategories {
        print("✅ FocalCategory.\(category): \(category.displayName)")
    }

    // Test LensFormatCategory enum
    let formatCategories: [LensFormatCategory] = [.s35, .ff, .mft, .s16, .other]
    for category in formatCategories {
        print("✅ LensFormatCategory.\(category): \(category.displayName)")
    }

    // Test ActiveTab enum
    let tabs: [ActiveTab] = [.allLenses, .favorites, .comparison, .camera, .rentals]
    for tab in tabs {
        print("✅ ActiveTab: \(tab)")
    }

    // Test DataLoadingState enum
    let states: [DataLoadingState] = [.idle, .loading, .loaded, .error]
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