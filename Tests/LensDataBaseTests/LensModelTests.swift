import XCTest
@testable import LensDataBase

final class LensModelTests: XCTestCase {
    
    func testLensInitialization() {
        // Test data
        let testLens = Lens(
            id: "test-1",
            display_name: "Test Lens",
            manufacturer: "Test Manufacturer",
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
        
        // Assertions
        XCTAssertEqual(testLens.id, "test-1")
        XCTAssertEqual(testLens.display_name, "Test Lens")
        XCTAssertEqual(testLens.manufacturer, "Test Manufacturer")
        XCTAssertEqual(testLens.lens_name, "Test Series")
        XCTAssertEqual(testLens.format, "FF")
        XCTAssertEqual(testLens.focal_length, "50mm")
        XCTAssertEqual(testLens.aperture, "f/1.4")
        XCTAssertNil(testLens.squeeze_factor)
    }
    
    func testMainFocalValueExtraction() {
        // Test single focal length
        let lens1 = Lens(
            id: "1", display_name: "", manufacturer: "", lens_name: "",
            format: "", focal_length: "50mm", aperture: "", close_focus_in: "",
            close_focus_cm: "", image_circle: "", length: "", front_diameter: "",
            squeeze_factor: nil
        )
        XCTAssertEqual(lens1.mainFocalValue, 50.0)
        
        // Test zoom range
        let lens2 = Lens(
            id: "2", display_name: "", manufacturer: "", lens_name: "",
            format: "", focal_length: "24-70mm", aperture: "", close_focus_in: "",
            close_focus_cm: "", image_circle: "", length: "", front_diameter: "",
            squeeze_factor: nil
        )
        XCTAssertEqual(lens2.mainFocalValue, 24.0)
        
        // Test with no numbers
        let lens3 = Lens(
            id: "3", display_name: "", manufacturer: "", lens_name: "",
            format: "", focal_length: "Variable", aperture: "", close_focus_in: "",
            close_focus_cm: "", image_circle: "", length: "", front_diameter: "",
            squeeze_factor: nil
        )
        XCTAssertNil(lens3.mainFocalValue)
    }
    
    func testLensDecoding() throws {
        let jsonData = """
        {
            "id": "lens-123",
            "display_name": "Canon EF 50mm f/1.4 USM",
            "manufacturer": "Canon",
            "lens_name": "EF 50mm f/1.4 USM",
            "format": "FF",
            "focal_length": "50mm",
            "aperture": "f/1.4",
            "close_focus_in": "18\"",
            "close_focus_cm": "45cm",
            "image_circle": "43.3mm",
            "length": "73.8mm",
            "front_diameter": "73.8mm",
            "squeeze_factor": null
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let lens = try decoder.decode(Lens.self, from: jsonData)
        
        XCTAssertEqual(lens.id, "lens-123")
        XCTAssertEqual(lens.manufacturer, "Canon")
        XCTAssertEqual(lens.lens_name, "EF 50mm f/1.4 USM")
        XCTAssertEqual(lens.format, "FF")
        XCTAssertEqual(lens.focal_length, "50mm")
        XCTAssertNil(lens.squeeze_factor)
    }
    
    func testLensFlexibleDecoding() throws {
        // Test with mixed data types
        let jsonData = """
        {
            "id": 123,
            "display_name": "Test Lens",
            "manufacturer": "Test",
            "lens_name": "Test Series",
            "format": "FF",
            "focal_length": 50,
            "aperture": "f/1.4",
            "close_focus_in": 18,
            "close_focus_cm": 45.5,
            "image_circle": "43.3mm",
            "length": "73.8mm",
            "front_diameter": "73.8mm",
            "squeeze_factor": true
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let lens = try decoder.decode(Lens.self, from: jsonData)
        
        XCTAssertEqual(lens.id, "123")
        XCTAssertEqual(lens.focal_length, "50")
        XCTAssertEqual(lens.close_focus_in, "18")
        XCTAssertEqual(lens.close_focus_cm, "45.5")
        XCTAssertEqual(lens.squeeze_factor, "true")
    }
}