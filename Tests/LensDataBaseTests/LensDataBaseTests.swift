import Foundation
@testable import LensDataBase
import XCTest

final class LensDataBaseTests: XCTestCase {
    // MARK: - Model Tests

    func testLensModelInitialization() {
        // Test lens model creation and properties
        let lens = Lens(
            id: "test-1",
            displayName: "Test Lens",
            manufacturer: "Test Corp",
            lensName: "Test 50mm",
            format: "Full Frame",
            focalLength: "50mm",
            aperture: "f/1.4",
            closeFocusIn: "18",
            closeFocusCm: "45",
            imageCircle: "43.3mm",
            length: "85mm",
            frontDiameter: "72mm",
            squeezeFactor: nil)

        XCTAssertEqual(lens.id, "test-1")
        XCTAssertEqual(lens.displayName, "Test Lens")
        XCTAssertEqual(lens.manufacturer, "Test Corp")
        XCTAssertEqual(lens.focalLength, "50mm")
        XCTAssertEqual(lens.aperture, "f/1.4")
        XCTAssertNil(lens.squeezeFactor)
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
            imageCircle: "43.3")

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
            website: "https://test.com")

        XCTAssertEqual(rental.id, "rental-1")
        XCTAssertEqual(rental.name, "Test Rental")
        XCTAssertEqual(rental.address, "123 Test St")
        XCTAssertEqual(rental.phone, "555-0123")
        XCTAssertEqual(rental.website, "https://test.com")
    }

    func testInventoryItemCreation() {
        // Test inventory item creation
        let item = InventoryItem(lensId: "lens-123")

        XCTAssertEqual(item.lensId, "lens-123")
    }

    func testInventoryItemJSONDecoding() {
        // Test inventory item JSON decoding with snake_case keys
        let jsonData = Data("""
        {
            "lens_id": "lens-456"
        }
        """.utf8)

        do {
            let item = try JSONDecoder().decode(InventoryItem.self, from: jsonData)
            XCTAssertEqual(item.lensId, "lens-456")
        } catch {
            XCTFail("Failed to decode InventoryItem JSON: \(error)")
        }
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
            recordingImageCircle: "43.3")

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
            .updateView,
        ]

        XCTAssertEqual(allTabs.count, 4)

        // Test each tab equals itself
        for activeTab in allTabs {
            XCTAssertEqual(activeTab, activeTab)
        }

        // Test tabs are not equal to each other
        XCTAssertNotEqual(ActiveTab.allLenses, ActiveTab.rentalView)
        XCTAssertNotEqual(ActiveTab.favorites, ActiveTab.updateView)
        XCTAssertNotEqual(ActiveTab.updateView, ActiveTab.allLenses)
    }

    // MARK: - Lens Group Tests

    func testLensGroupCreation() {
        // Test lens grouping structures
        let testLens1 = Lens(
            id: "test-1",
            displayName: "Test Lens 1",
            manufacturer: "Test Corp",
            lensName: "Test 50mm",
            format: "Full Frame",
            focalLength: "50mm",
            aperture: "f/1.4",
            closeFocusIn: "18",
            closeFocusCm: "45",
            imageCircle: "43.3mm",
            length: "85mm",
            frontDiameter: "72mm",
            squeezeFactor: nil)

        let testLens2 = Lens(
            id: "test-2",
            displayName: "Test Lens 2",
            manufacturer: "Test Corp",
            lensName: "Test 85mm",
            format: "Full Frame",
            focalLength: "85mm",
            aperture: "f/1.8",
            closeFocusIn: "24",
            closeFocusCm: "60",
            imageCircle: "43.3mm",
            length: "90mm",
            frontDiameter: "77mm",
            squeezeFactor: nil)

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
            Lens(
                id: "1",
                displayName: "Lens 1",
                manufacturer: "Corp",
                lensName: "L1",
                format: "FF",
                focalLength: "50",
                aperture: "f/1.4",
                closeFocusIn: "18",
                closeFocusCm: "45",
                imageCircle: "43.3",
                length: "85",
                frontDiameter: "72",
                squeezeFactor: nil),
            Lens(
                id: "2",
                displayName: "Lens 2",
                manufacturer: "Corp",
                lensName: "L2",
                format: "FF",
                focalLength: "85",
                aperture: "f/1.8",
                closeFocusIn: "24",
                closeFocusCm: "60",
                imageCircle: "43.3",
                length: "90",
                frontDiameter: "77",
                squeezeFactor: nil),
        ]

        let series = LensSeries(name: "Prime Series", lenses: lenses)

        XCTAssertEqual(series.name, "Prime Series")
        XCTAssertEqual(series.lenses.count, 2)
        XCTAssertEqual(series.lenses[0].focalLength, "50")
        XCTAssertEqual(series.lenses[1].focalLength, "85")
    }

    // MARK: - Performance Tests

    func testLensArrayFiltering() {
        // Test performance of lens array operations
        let lenses = (0..<1_000).map { index in
            Lens(
                id: "lens-\(index)",
                displayName: "Test Lens \(index)",
                manufacturer: index % 2 == 0 ? "Canon" : "Sony",
                lensName: "Test \(index)mm",
                format: "Full Frame",
                focalLength: "\(index)mm",
                aperture: "f/1.4",
                closeFocusIn: "18",
                closeFocusCm: "45",
                imageCircle: "43.3mm",
                length: "85mm",
                frontDiameter: "72mm",
                squeezeFactor: nil)
        }

        let canonLenses = lenses.filter { $0.manufacturer == "Canon" }
        let sonyLenses = lenses.filter { $0.manufacturer == "Sony" }

        XCTAssertEqual(canonLenses.count, 500)
        XCTAssertEqual(sonyLenses.count, 500)
    }

    func testLensArraySorting() {
        // Test lens array sorting
        let lenses = [
            Lens(
                id: "1",
                displayName: "Zebra",
                manufacturer: "Canon",
                lensName: "Z",
                format: "FF",
                focalLength: "100",
                aperture: "f/2.8",
                closeFocusIn: "50",
                closeFocusCm: "127",
                imageCircle: "43.3",
                length: "200",
                frontDiameter: "82",
                squeezeFactor: nil),
            Lens(
                id: "2",
                displayName: "Alpha",
                manufacturer: "Sony",
                lensName: "A",
                format: "FF",
                focalLength: "50",
                aperture: "f/1.4",
                closeFocusIn: "18",
                closeFocusCm: "45",
                imageCircle: "43.3",
                length: "85",
                frontDiameter: "72",
                squeezeFactor: nil),
            Lens(
                id: "3",
                displayName: "Beta",
                manufacturer: "Nikon",
                lensName: "B",
                format: "FF",
                focalLength: "85",
                aperture: "f/1.8",
                closeFocusIn: "24",
                closeFocusCm: "60",
                imageCircle: "43.3",
                length: "90",
                frontDiameter: "77",
                squeezeFactor: nil),
        ]

        let sortedByName = lenses.sorted { $0.displayName < $1.displayName }
        let sortedByFocalLength = lenses
            .sorted {
                Int($0.focalLength.replacingOccurrences(of: "mm", with: "")) ?? 0 <
                    Int($1.focalLength.replacingOccurrences(
                        of: "mm",
                        with: "")) ?? 0
            }

        XCTAssertEqual(sortedByName[0].displayName, "Alpha")
        XCTAssertEqual(sortedByName[1].displayName, "Beta")
        XCTAssertEqual(sortedByName[2].displayName, "Zebra")

        XCTAssertEqual(sortedByFocalLength[0].focalLength, "50")
        XCTAssertEqual(sortedByFocalLength[1].focalLength, "85")
        XCTAssertEqual(sortedByFocalLength[2].focalLength, "100")
    }

    // MARK: - JSON Decoding Tests

    func testLensJSONDecoding() {
        // Test lens JSON decoding with various data types
        let jsonData = Data("""
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
        """.utf8)

        do {
            let lens = try JSONDecoder().decode(Lens.self, from: jsonData)
            XCTAssertEqual(lens.id, "lens-1")
            XCTAssertEqual(lens.displayName, "Test Lens")
            XCTAssertEqual(lens.manufacturer, "Canon")
            XCTAssertEqual(lens.focalLength, "50")
            XCTAssertEqual(lens.closeFocusIn, "18")
            XCTAssertEqual(lens.closeFocusCm, "45.7")
            XCTAssertEqual(lens.frontDiameter, "72")
            XCTAssertNil(lens.squeezeFactor)
        } catch {
            XCTFail("Failed to decode lens JSON: \(error)")
        }
    }
}
