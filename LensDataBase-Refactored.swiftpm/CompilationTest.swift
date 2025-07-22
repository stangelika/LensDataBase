import Foundation

// Test compilation of the main components
func testCompilation() {
    // Test domain models
    let lens = Lens(
        id: "test",
        displayName: "Test Lens",
        manufacturer: "Test Manufacturer",
        model: "Test Model",
        specifications: LensSpecifications(
            format: "Test Format",
            focalLength: "50mm",
            aperture: "2.8",
            closeFocusDistance: CloseFocusDistance(inches: "12", centimeters: "30"),
            imageCircle: nil,
            squeezeFactor: nil
        ),
        physicalProperties: PhysicalProperties(
            length: "100mm",
            frontDiameter: "80mm",
            weight: nil
        ),
        compatibility: LensCompatibility(
            mount: nil,
            supportedFormats: ["Test Format"],
            recommendedCameras: []
        )
    )
    
    // Test filtering
    let category = FocalLengthCategory.standard
    print("Testing focal category: \(category.displayName)")
    print("Contains 50mm: \(category.contains(50.0))")
    
    // Test domain mapper
    let apiLens = APILens(
        id: "1",
        display_name: "Test API Lens",
        manufacturer: "Test Manufacturer",
        lens_name: "Test Model",
        format: "Test Format",
        focal_length: "50mm",
        aperture: "2.8",
        close_focus_in: "12",
        close_focus_cm: "30",
        image_circle: "",
        length: "100mm",
        front_diameter: "80mm",
        squeeze_factor: nil,
        lens_format: nil
    )
    
    let domainLens = DomainMapper.mapToDomain(apiLens: apiLens)
    print("Mapped lens: \(domainLens.displayName)")
    
    print("✅ Compilation test passed!")
}

// Run test
testCompilation()