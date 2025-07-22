import Foundation

/**
 * Basic compilation test for LensDataBase Swift Playground project
 * This file verifies that all components can be imported and instantiated correctly
 */

func testBasicCompilation() {
    print("🧪 Testing basic compilation...")
    
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
    
    // Test enums work correctly
    let focalCategory = FocalCategory.standard
    print("✅ FocalCategory: \(focalCategory.displayName)")
    
    let lensFormatCategory = LensFormatCategory.ff
    print("✅ LensFormatCategory: \(lensFormatCategory.displayName)")
    
    let activeTab = ActiveTab.allLenses
    print("✅ ActiveTab: \(activeTab)")
    
    // Test data loading state
    let loadingState = DataLoadingState.idle
    print("✅ DataLoadingState: \(loadingState)")
    
    print("🎉 All basic compilation tests passed!")
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

// Manual instantiation to test compilation
// This will only run when explicitly called
#if DEBUG
// Uncomment the line below to run the test
// testBasicCompilation()
#endif