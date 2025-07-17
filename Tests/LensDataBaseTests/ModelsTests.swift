import XCTest
@testable import LensDataBase

final class ModelsTests: XCTestCase {
    
    // MARK: - Camera Model Tests
    
    func testCameraDecoding() throws {
        let jsonData = """
        {
            "id": "123",
            "manufacturer": "Canon",
            "model": "EOS R5",
            "sensor": "Full Frame",
            "sensorwidth": "36.0",
            "sensorheight": "24.0",
            "imagecircle": "43.3"
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let camera = try decoder.decode(Camera.self, from: jsonData)
        
        XCTAssertEqual(camera.id, "123")
        XCTAssertEqual(camera.manufacturer, "Canon")
        XCTAssertEqual(camera.model, "EOS R5")
        XCTAssertEqual(camera.sensor, "Full Frame")
        XCTAssertEqual(camera.sensorWidth, "36.0")
        XCTAssertEqual(camera.sensorHeight, "24.0")
        XCTAssertEqual(camera.imageCircle, "43.3")
    }
    
    func testCameraHashable() {
        let camera1 = Camera(
            id: "123",
            manufacturer: "Canon",
            model: "EOS R5",
            sensor: "Full Frame",
            sensorWidth: "36.0",
            sensorHeight: "24.0",
            imageCircle: "43.3"
        )
        
        let camera2 = Camera(
            id: "123",
            manufacturer: "Canon",
            model: "EOS R5",
            sensor: "Full Frame",
            sensorWidth: "36.0",
            sensorHeight: "24.0",
            imageCircle: "43.3"
        )
        
        XCTAssertEqual(camera1, camera2)
        XCTAssertEqual(camera1.hashValue, camera2.hashValue)
    }
    
    // MARK: - RecordingFormat Model Tests
    
    func testRecordingFormatDecoding() throws {
        let jsonData = """
        {
            "id": "456",
            "cameraid": "123",
            "manufacturer": "Canon",
            "model": "EOS R5",
            "sensorwidth": "36.0",
            "sensorheight": "24.0",
            "recordingformat": "4K UHD",
            "recordingwidth": "3840",
            "recordingheight": "2160",
            "recordingimagecircle": "43.3"
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let format = try decoder.decode(RecordingFormat.self, from: jsonData)
        
        XCTAssertEqual(format.id, "456")
        XCTAssertEqual(format.cameraId, "123")
        XCTAssertEqual(format.manufacturer, "Canon")
        XCTAssertEqual(format.model, "EOS R5")
        XCTAssertEqual(format.sensorWidth, "36.0")
        XCTAssertEqual(format.sensorHeight, "24.0")
        XCTAssertEqual(format.recordingFormat, "4K UHD")
        XCTAssertEqual(format.recordingWidth, "3840")
        XCTAssertEqual(format.recordingHeight, "2160")
        XCTAssertEqual(format.recordingImageCircle, "43.3")
    }
    
    // MARK: - Lens Model Tests
    
    func testLensFlexibleDecoding() throws {
        let jsonData = """
        {
            "id": "789",
            "display_name": "Canon EF 50mm f/1.8",
            "manufacturer": "Canon",
            "lens_name": "EF 50mm f/1.8",
            "format": "Full Frame",
            "focal_length": "50",
            "aperture": "f/1.8",
            "close_focus_in": "18",
            "close_focus_cm": "45.7",
            "image_circle": "43.3",
            "length": "69",
            "front_diameter": "67",
            "squeeze_factor": null
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let lens = try decoder.decode(Lens.self, from: jsonData)
        
        XCTAssertEqual(lens.id, "789")
        XCTAssertEqual(lens.display_name, "Canon EF 50mm f/1.8")
        XCTAssertEqual(lens.manufacturer, "Canon")
        XCTAssertEqual(lens.lens_name, "EF 50mm f/1.8")
        XCTAssertEqual(lens.format, "Full Frame")
        XCTAssertEqual(lens.focal_length, "50")
        XCTAssertEqual(lens.aperture, "f/1.8")
        XCTAssertEqual(lens.close_focus_in, "18")
        XCTAssertEqual(lens.close_focus_cm, "45.7")
        XCTAssertEqual(lens.image_circle, "43.3")
        XCTAssertEqual(lens.length, "69")
        XCTAssertEqual(lens.front_diameter, "67")
        XCTAssertNil(lens.squeeze_factor)
    }
    
    func testLensFlexibleDecodingWithDifferentTypes() throws {
        let jsonData = """
        {
            "id": 789,
            "display_name": "Canon EF 50mm f/1.8",
            "manufacturer": "Canon",
            "lens_name": "EF 50mm f/1.8",
            "format": "Full Frame",
            "focal_length": 50,
            "aperture": "f/1.8",
            "close_focus_in": 18.0,
            "close_focus_cm": 45.7,
            "image_circle": 43.3,
            "length": 69,
            "front_diameter": 67,
            "squeeze_factor": 1.33
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let lens = try decoder.decode(Lens.self, from: jsonData)
        
        XCTAssertEqual(lens.id, "789")
        XCTAssertEqual(lens.focal_length, "50")
        XCTAssertEqual(lens.close_focus_in, "18.0")
        XCTAssertEqual(lens.close_focus_cm, "45.7")
        XCTAssertEqual(lens.image_circle, "43.3")
        XCTAssertEqual(lens.length, "69")
        XCTAssertEqual(lens.front_diameter, "67")
        XCTAssertEqual(lens.squeeze_factor, "1.33")
    }
    
    // MARK: - Rental Model Tests
    
    func testRentalDecoding() throws {
        let jsonData = """
        {
            "id": "rental123",
            "name": "Camera Rental Pro",
            "address": "123 Main St, New York, NY",
            "phone": "+1-555-123-4567",
            "website": "https://camerarentalpro.com"
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let rental = try decoder.decode(Rental.self, from: jsonData)
        
        XCTAssertEqual(rental.id, "rental123")
        XCTAssertEqual(rental.name, "Camera Rental Pro")
        XCTAssertEqual(rental.address, "123 Main St, New York, NY")
        XCTAssertEqual(rental.phone, "+1-555-123-4567")
        XCTAssertEqual(rental.website, "https://camerarentalpro.com")
    }
    
    // MARK: - AppData Model Tests
    
    func testAppDataDecoding() throws {
        let jsonData = """
        {
            "last_updated": "2024-01-01T00:00:00Z",
            "rentals": [
                {
                    "id": "rental123",
                    "name": "Camera Rental Pro",
                    "address": "123 Main St, New York, NY",
                    "phone": "+1-555-123-4567",
                    "website": "https://camerarentalpro.com"
                }
            ],
            "lenses": [
                {
                    "id": "789",
                    "display_name": "Canon EF 50mm f/1.8",
                    "manufacturer": "Canon",
                    "lens_name": "EF 50mm f/1.8",
                    "format": "Full Frame",
                    "focal_length": "50",
                    "aperture": "f/1.8",
                    "close_focus_in": "18",
                    "close_focus_cm": "45.7",
                    "image_circle": "43.3",
                    "length": "69",
                    "front_diameter": "67",
                    "squeeze_factor": null
                }
            ],
            "inventory": {
                "rental123": [
                    {
                        "lens_id": "789"
                    }
                ]
            }
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let appData = try decoder.decode(AppData.self, from: jsonData)
        
        XCTAssertEqual(appData.last_updated, "2024-01-01T00:00:00Z")
        XCTAssertEqual(appData.rentals.count, 1)
        XCTAssertEqual(appData.lenses.count, 1)
        XCTAssertEqual(appData.inventory.count, 1)
        XCTAssertEqual(appData.inventory["rental123"]?.count, 1)
        XCTAssertEqual(appData.inventory["rental123"]?.first?.lens_id, "789")
    }
    
    func testAppDataFiltersEmptyLenses() throws {
        let jsonData = """
        {
            "last_updated": "2024-01-01T00:00:00Z",
            "rentals": [],
            "lenses": [
                {
                    "id": "",
                    "display_name": "Empty Lens",
                    "manufacturer": "Test",
                    "lens_name": "Test",
                    "format": "Test",
                    "focal_length": "50",
                    "aperture": "f/1.8",
                    "close_focus_in": "18",
                    "close_focus_cm": "45.7",
                    "image_circle": "43.3",
                    "length": "69",
                    "front_diameter": "67",
                    "squeeze_factor": null
                },
                {
                    "id": "valid123",
                    "display_name": "Valid Lens",
                    "manufacturer": "Canon",
                    "lens_name": "EF 50mm f/1.8",
                    "format": "Full Frame",
                    "focal_length": "50",
                    "aperture": "f/1.8",
                    "close_focus_in": "18",
                    "close_focus_cm": "45.7",
                    "image_circle": "43.3",
                    "length": "69",
                    "front_diameter": "67",
                    "squeeze_factor": null
                }
            ],
            "inventory": {}
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let appData = try decoder.decode(AppData.self, from: jsonData)
        
        // Should filter out lens with empty ID
        XCTAssertEqual(appData.lenses.count, 1)
        XCTAssertEqual(appData.lenses.first?.id, "valid123")
    }
    
    // MARK: - DataLoadingState Tests
    
    func testDataLoadingStateEquality() {
        XCTAssertEqual(DataLoadingState.idle, DataLoadingState.idle)
        XCTAssertEqual(DataLoadingState.loading, DataLoadingState.loading)
        XCTAssertEqual(DataLoadingState.loaded, DataLoadingState.loaded)
        XCTAssertEqual(DataLoadingState.error("Test error"), DataLoadingState.error("Test error"))
        
        XCTAssertNotEqual(DataLoadingState.idle, DataLoadingState.loading)
        XCTAssertNotEqual(DataLoadingState.error("Error 1"), DataLoadingState.error("Error 2"))
    }
    
    // MARK: - ActiveTab Tests
    
    func testActiveTabEquality() {
        XCTAssertEqual(ActiveTab.rentalView, ActiveTab.rentalView)
        XCTAssertEqual(ActiveTab.allLenses, ActiveTab.allLenses)
        XCTAssertEqual(ActiveTab.updateView, ActiveTab.updateView)
        XCTAssertEqual(ActiveTab.favorites, ActiveTab.favorites)
        
        XCTAssertNotEqual(ActiveTab.rentalView, ActiveTab.allLenses)
        XCTAssertNotEqual(ActiveTab.updateView, ActiveTab.favorites)
    }
    
    // MARK: - LensGroup and LensSeries Tests
    
    func testLensGroupInitialization() {
        let lens = createTestLens()
        
        let lensSeries = LensSeries(name: "Test Series", lenses: [lens])
        let lensGroup = LensGroup(manufacturer: "Test Corp", series: [lensSeries])
        
        XCTAssertEqual(lensGroup.manufacturer, "Test Corp")
        XCTAssertEqual(lensGroup.series.count, 1)
        XCTAssertEqual(lensGroup.series.first?.name, "Test Series")
        XCTAssertEqual(lensGroup.series.first?.lenses.count, 1)
        XCTAssertEqual(lensGroup.series.first?.lenses.first?.id, "test123")
    }
    
    // MARK: - Helper Methods
    
    private func createTestLens() -> Lens {
        return Lens(
            id: "test123",
            display_name: "Test Lens",
            manufacturer: "Test Corp",
            lens_name: "Test 50mm",
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

extension Lens {
    init(id: String, display_name: String, manufacturer: String, lens_name: String, format: String, focal_length: String, aperture: String, close_focus_in: String, close_focus_cm: String, image_circle: String, length: String, front_diameter: String, squeeze_factor: String?) {
        self.id = id
        self.display_name = display_name
        self.manufacturer = manufacturer
        self.lens_name = lens_name
        self.format = format
        self.focal_length = focal_length
        self.aperture = aperture
        self.close_focus_in = close_focus_in
        self.close_focus_cm = close_focus_cm
        self.image_circle = image_circle
        self.length = length
        self.front_diameter = front_diameter
        self.squeeze_factor = squeeze_factor
    }
}

extension Camera {
    init(id: String, manufacturer: String, model: String, sensor: String, sensorWidth: String, sensorHeight: String, imageCircle: String) {
        self.id = id
        self.manufacturer = manufacturer
        self.model = model
        self.sensor = sensor
        self.sensorWidth = sensorWidth
        self.sensorHeight = sensorHeight
        self.imageCircle = imageCircle
    }
}