// LensDataBaseTests.swift

import XCTest
import Foundation
@testable import LensDataBase

final class LensDataBaseTests: XCTestCase {
    
    // MARK: - Model Tests
    
    func testLensModelInitialization() {
        // Test lens model creation and properties
        let lens = Lens(
            id: "test-1",
            display_name: "Test Lens",
            manufacturer: "Test Corp",
            lens_name: "Test 50mm",
            format: "Full Frame",
            focal_length: "50mm",
            aperture: "f/1.4",
            close_focus_in: "18",
            close_focus_cm: "45",
            image_circle: "43.3mm",
            length: "85mm",
            front_diameter: "72mm",
            squeeze_factor: nil
        )
        
        XCTAssertEqual(lens.id, "test-1")
        XCTAssertEqual(lens.display_name, "Test Lens")
        XCTAssertEqual(lens.manufacturer, "Test Corp")
        XCTAssertEqual(lens.focal_length, "50mm")
        XCTAssertEqual(lens.aperture, "f/1.4")
        XCTAssertNil(lens.squeeze_factor)
    }
    
    func testProjectModelCreation() {
        // Test project model creation
        let project = Project.empty()
        
        XCTAssertEqual(project.name, "New Project")
        XCTAssertEqual(project.notes, "")
        XCTAssertTrue(project.lensIDs.isEmpty)
        XCTAssertTrue(project.cameraIDs.isEmpty)
        XCTAssertNotNil(project.id)
    }
    
    func testProjectModelModification() {
        // Test project modification
        var project = Project.empty()
        project.name = "Modified Project"
        project.lensIDs = ["lens-1", "lens-2"]
        project.notes = "Test notes"
        
        XCTAssertEqual(project.name, "Modified Project")
        XCTAssertEqual(project.lensIDs.count, 2)
        XCTAssertEqual(project.lensIDs, ["lens-1", "lens-2"])
        XCTAssertEqual(project.notes, "Test notes")
    }
    
    func testCameraModelCreation() {
        // Test camera model creation
        let camera = Camera(
            id: "cam-1",
            manufacturer: "Canon",
            model: "EOS R5",
            sensor: "CMOS",
            sensorWidth: "36",
            sensorHeight: "24",
            imageCircle: "43.3"
        )
        
        XCTAssertEqual(camera.id, "cam-1")
        XCTAssertEqual(camera.manufacturer, "Canon")
        XCTAssertEqual(camera.model, "EOS R5")
        XCTAssertEqual(camera.sensor, "CMOS")
        XCTAssertEqual(camera.sensorWidth, "36")
        XCTAssertEqual(camera.sensorHeight, "24")
        XCTAssertEqual(camera.imageCircle, "43.3")
    }
    
    func testRentalModelCreation() {
        // Test rental model creation
        let rental = Rental(
            id: "rental-1",
            name: "Test Rental",
            address: "123 Test St",
            phone: "555-0123",
            website: "https://test.com"
        )
        
        XCTAssertEqual(rental.id, "rental-1")
        XCTAssertEqual(rental.name, "Test Rental")
        XCTAssertEqual(rental.address, "123 Test St")
        XCTAssertEqual(rental.phone, "555-0123")
        XCTAssertEqual(rental.website, "https://test.com")
    }
    
    func testInventoryItemCreation() {
        // Test inventory item creation
        let item = InventoryItem(lens_id: "lens-123")
        
        XCTAssertEqual(item.lens_id, "lens-123")
    }
    
    func testRecordingFormatCreation() {
        // Test recording format creation
        let format = RecordingFormat(
            id: "format-1",
            cameraId: "cam-1",
            manufacturer: "Canon",
            model: "EOS R5",
            sensorWidth: "36",
            sensorHeight: "24",
            recordingFormat: "4K",
            recordingWidth: "3840",
            recordingHeight: "2160",
            recordingImageCircle: "43.3"
        )
        
        XCTAssertEqual(format.id, "format-1")
        XCTAssertEqual(format.cameraId, "cam-1")
        XCTAssertEqual(format.manufacturer, "Canon")
        XCTAssertEqual(format.recordingFormat, "4K")
        XCTAssertEqual(format.recordingWidth, "3840")
        XCTAssertEqual(format.recordingHeight, "2160")
    }
    
    // MARK: - Data Loading State Tests
    
    func testDataLoadingStateEquality() {
        // Test all loading states
        let idle = DataLoadingState.idle
        let loading = DataLoadingState.loading
        let loaded = DataLoadingState.loaded
        let error1 = DataLoadingState.error("Test error")
        let error2 = DataLoadingState.error("Test error")
        let error3 = DataLoadingState.error("Different error")
        
        XCTAssertEqual(idle, .idle)
        XCTAssertEqual(loading, .loading)
        XCTAssertEqual(loaded, .loaded)
        XCTAssertEqual(error1, error2)
        XCTAssertNotEqual(error1, error3)
    }
    
    func testDataLoadingStateErrorMessage() {
        // Test error state message extraction
        let errorMessage = "Network connection failed"
        let errorState = DataLoadingState.error(errorMessage)
        
        if case .error(let message) = errorState {
            XCTAssertEqual(message, errorMessage)
        } else {
            XCTFail("Expected error state with message")
        }
    }
    
    // MARK: - Active Tab Tests
    
    func testActiveTabEquality() {
        // Test all tab cases
        let allTabs: [ActiveTab] = [
            .allLenses,
            .rentalView,
            .favorites,
            .projects,
            .updateView
        ]
        
        XCTAssertEqual(allTabs.count, 5)
        
        // Test each tab equals itself
        for tab in allTabs {
            XCTAssertEqual(tab, tab)
        }
        
        // Test tabs are not equal to each other
        XCTAssertNotEqual(ActiveTab.allLenses, ActiveTab.rentalView)
        XCTAssertNotEqual(ActiveTab.favorites, ActiveTab.projects)
        XCTAssertNotEqual(ActiveTab.updateView, ActiveTab.allLenses)
    }
    
    // MARK: - Lens Group Tests
    
    func testLensGroupCreation() {
        // Test lens grouping structures
        let testLens1 = Lens(
            id: "test-1",
            display_name: "Test Lens 1",
            manufacturer: "Test Corp",
            lens_name: "Test 50mm",
            format: "Full Frame",
            focal_length: "50mm",
            aperture: "f/1.4",
            close_focus_in: "18",
            close_focus_cm: "45",
            image_circle: "43.3mm",
            length: "85mm",
            front_diameter: "72mm",
            squeeze_factor: nil
        )
        
        let testLens2 = Lens(
            id: "test-2",
            display_name: "Test Lens 2",
            manufacturer: "Test Corp",
            lens_name: "Test 85mm",
            format: "Full Frame",
            focal_length: "85mm",
            aperture: "f/1.8",
            close_focus_in: "24",
            close_focus_cm: "60",
            image_circle: "43.3mm",
            length: "90mm",
            front_diameter: "77mm",
            squeeze_factor: nil
        )
        
        let lensSeries = LensSeries(name: "Test Series", lenses: [testLens1, testLens2])
        let lensGroup = LensGroup(manufacturer: "Test Corp", series: [lensSeries])
        
        XCTAssertEqual(lensGroup.manufacturer, "Test Corp")
        XCTAssertEqual(lensGroup.series.count, 1)
        XCTAssertEqual(lensGroup.series[0].name, "Test Series")
        XCTAssertEqual(lensGroup.series[0].lenses.count, 2)
        XCTAssertEqual(lensGroup.series[0].lenses[0].id, "test-1")
        XCTAssertEqual(lensGroup.series[0].lenses[1].id, "test-2")
    }
    
    func testLensSeriesCreation() {
        // Test lens series creation
        let lenses = [
            Lens(id: "1", display_name: "Lens 1", manufacturer: "Corp", lens_name: "L1", format: "FF", focal_length: "50", aperture: "f/1.4", close_focus_in: "18", close_focus_cm: "45", image_circle: "43.3", length: "85", front_diameter: "72", squeeze_factor: nil),
            Lens(id: "2", display_name: "Lens 2", manufacturer: "Corp", lens_name: "L2", format: "FF", focal_length: "85", aperture: "f/1.8", close_focus_in: "24", close_focus_cm: "60", image_circle: "43.3", length: "90", front_diameter: "77", squeeze_factor: nil)
        ]
        
        let series = LensSeries(name: "Prime Series", lenses: lenses)
        
        XCTAssertEqual(series.name, "Prime Series")
        XCTAssertEqual(series.lenses.count, 2)
        XCTAssertEqual(series.lenses[0].focal_length, "50")
        XCTAssertEqual(series.lenses[1].focal_length, "85")
    }
    
    // MARK: - Performance Tests
    
    func testLensArrayFiltering() {
        // Test performance of lens array operations
        let lenses = (0..<1000).map { index in
            Lens(
                id: "lens-\(index)",
                display_name: "Test Lens \(index)",
                manufacturer: index % 2 == 0 ? "Canon" : "Sony",
                lens_name: "Test \(index)mm",
                format: "Full Frame",
                focal_length: "\(index)mm",
                aperture: "f/1.4",
                close_focus_in: "18",
                close_focus_cm: "45",
                image_circle: "43.3mm",
                length: "85mm",
                front_diameter: "72mm",
                squeeze_factor: nil
            )
        }
        
        let canonLenses = lenses.filter { $0.manufacturer == "Canon" }
        let sonyLenses = lenses.filter { $0.manufacturer == "Sony" }
        
        XCTAssertEqual(canonLenses.count, 500)
        XCTAssertEqual(sonyLenses.count, 500)
    }
    
    func testLensArraySorting() {
        // Test lens array sorting
        let lenses = [
            Lens(id: "1", display_name: "Zebra", manufacturer: "Canon", lens_name: "Z", format: "FF", focal_length: "100", aperture: "f/2.8", close_focus_in: "50", close_focus_cm: "127", image_circle: "43.3", length: "200", front_diameter: "82", squeeze_factor: nil),
            Lens(id: "2", display_name: "Alpha", manufacturer: "Sony", lens_name: "A", format: "FF", focal_length: "50", aperture: "f/1.4", close_focus_in: "18", close_focus_cm: "45", image_circle: "43.3", length: "85", front_diameter: "72", squeeze_factor: nil),
            Lens(id: "3", display_name: "Beta", manufacturer: "Nikon", lens_name: "B", format: "FF", focal_length: "85", aperture: "f/1.8", close_focus_in: "24", close_focus_cm: "60", image_circle: "43.3", length: "90", front_diameter: "77", squeeze_factor: nil)
        ]
        
        let sortedByName = lenses.sorted { $0.display_name < $1.display_name }
        let sortedByFocalLength = lenses.sorted { Int($0.focal_length.replacingOccurrences(of: "mm", with: "")) ?? 0 < Int($1.focal_length.replacingOccurrences(of: "mm", with: "")) ?? 0 }
        
        XCTAssertEqual(sortedByName[0].display_name, "Alpha")
        XCTAssertEqual(sortedByName[1].display_name, "Beta")
        XCTAssertEqual(sortedByName[2].display_name, "Zebra")
        
        XCTAssertEqual(sortedByFocalLength[0].focal_length, "50")
        XCTAssertEqual(sortedByFocalLength[1].focal_length, "85")
        XCTAssertEqual(sortedByFocalLength[2].focal_length, "100")
    }
    
    // MARK: - JSON Decoding Tests
    
    func testLensJSONDecoding() {
        // Test lens JSON decoding with various data types
        let jsonData = """
        {
            "id": "lens-1",
            "display_name": "Test Lens",
            "manufacturer": "Canon",
            "lens_name": "EF 50mm f/1.4",
            "format": "Full Frame",
            "focal_length": 50,
            "aperture": "f/1.4",
            "close_focus_in": 18,
            "close_focus_cm": 45.7,
            "image_circle": "43.3mm",
            "length": "85mm",
            "front_diameter": 72,
            "squeeze_factor": null
        }
        """.data(using: .utf8)!
        
        do {
            let lens = try JSONDecoder().decode(Lens.self, from: jsonData)
            XCTAssertEqual(lens.id, "lens-1")
            XCTAssertEqual(lens.display_name, "Test Lens")
            XCTAssertEqual(lens.manufacturer, "Canon")
            XCTAssertEqual(lens.focal_length, "50")
            XCTAssertEqual(lens.close_focus_in, "18")
            XCTAssertEqual(lens.close_focus_cm, "45.7")
            XCTAssertEqual(lens.front_diameter, "72")
            XCTAssertNil(lens.squeeze_factor)
        } catch {
            XCTFail("Failed to decode lens JSON: \(error)")
        }
    }
}