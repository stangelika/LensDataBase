import Foundation

struct CameraApiResponse: Codable {
    let camera: [Camera]
    let formats: [RecordingFormat]
}

struct Camera: Codable, Identifiable, Hashable {
    let id: String
    let manufacturer: String
    let model: String
    let sensor: String
    let sensorWidth: String
    let sensorHeight: String
    let imageCircle: String
    
    private enum CodingKeys: String, CodingKey {
        case id, manufacturer, model, sensor
        case sensorWidth = "sensorwidth"
        case sensorHeight = "sensorheight"
        case imageCircle = "imagecircle"
    }
}

struct RecordingFormat: Codable, Identifiable, Hashable {
    let id: String
    let cameraId: String
    let manufacturer: String
    let model: String
    let sensorWidth: String
    let sensorHeight: String
    let recordingFormat: String
    let recordingWidth: String
    let recordingHeight: String
    let recordingImageCircle: String
    
    private enum CodingKeys: String, CodingKey {
        case id, manufacturer, model
        case cameraId = "cameraid"
        case sensorWidth = "sensorwidth"
        case sensorHeight = "sensorheight"
        case recordingFormat = "recordingformat"
        case recordingWidth = "recordingwidth"
        case recordingHeight = "recordingheight"
        case recordingImageCircle = "recordingimagecircle"
    }
}

struct Rental: Codable, Identifiable {
    let id: String
    let name: String
    let address: String
    let phone: String
    let website: String
}

struct Lens: Codable, Identifiable, Hashable {
    let id: String
    let display_name: String
    let manufacturer: String
    let lens_name: String
    let format: String
    let focal_length: String
    let aperture: String
    let close_focus_in: String
    let close_focus_cm: String
    let image_circle: String
    let length: String
    let front_diameter: String
    let squeeze_factor: String?
    let lens_format: String? // ✅ добавим, если ещё нет
    
    enum CodingKeys: String, CodingKey {
        case id, display_name, manufacturer, lens_name, format,
             focal_length, aperture, close_focus_in, close_focus_cm,
             image_circle, length, front_diameter, squeeze_factor,
             lens_format
    }
    
    // ... остальной код без изменений

    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try Lens.decodeFlexible(container: container, key: .id) ?? ""
        display_name = try Lens.decodeFlexible(container: container, key: .display_name) ?? ""
        manufacturer = try Lens.decodeFlexible(container: container, key: .manufacturer) ?? ""
        lens_name = try Lens.decodeFlexible(container: container, key: .lens_name) ?? ""
        format = try Lens.decodeFlexible(container: container, key: .format) ?? ""
        focal_length = try Lens.decodeFlexible(container: container, key: .focal_length) ?? ""
        aperture = try Lens.decodeFlexible(container: container, key: .aperture) ?? ""
        close_focus_in = try Lens.decodeFlexible(container: container, key: .close_focus_in) ?? ""
        close_focus_cm = try Lens.decodeFlexible(container: container, key: .close_focus_cm) ?? ""
        image_circle = try Lens.decodeFlexible(container: container, key: .image_circle) ?? ""
        length = try Lens.decodeFlexible(container: container, key: .length) ?? ""
        front_diameter = try Lens.decodeFlexible(container: container, key: .front_diameter) ?? ""
        squeeze_factor = try Lens.decodeFlexible(container: container, key: .squeeze_factor)
        lens_format = try Lens.decodeFlexible(container: container, key: .lens_format) ?? ""
    }
    
    private static func decodeFlexible(container: KeyedDecodingContainer<CodingKeys>, key: CodingKeys) throws -> String? {
        if let stringValue = try? container.decode(String.self, forKey: key) {
            return stringValue
        } else if let intValue = try? container.decode(Int.self, forKey: key) {
            return String(intValue)
        } else if let doubleValue = try? container.decode(Double.self, forKey: key) {
            return String(doubleValue)
        } else if let boolValue = try? container.decode(Bool.self, forKey: key) {
            return boolValue ? "true" : "false"
        } else {
            return nil
        }
    }
}

struct InventoryItem: Codable {
    let id: String
    let rental_id: String
    let lens_id: String
    let display_name: String?
    let notes: String?
    
    enum CodingKeys: String, CodingKey {
        case id, rental_id, lens_id, display_name, notes
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try InventoryItem.decodeFlexible(container: container, key: .id) ?? ""
        rental_id = try InventoryItem.decodeFlexible(container: container, key: .rental_id) ?? ""
        lens_id = try InventoryItem.decodeFlexible(container: container, key: .lens_id) ?? ""
        display_name = try? container.decodeIfPresent(String.self, forKey: .display_name)
        notes = try? container.decodeIfPresent(String.self, forKey: .notes)
    }
    
    private static func decodeFlexible(container: KeyedDecodingContainer<CodingKeys>, key: CodingKeys) throws -> String? {
        if let stringValue = try? container.decode(String.self, forKey: key) {
            return stringValue
        } else if let intValue = try? container.decode(Int.self, forKey: key) {
            return String(intValue)
        } else if let doubleValue = try? container.decode(Double.self, forKey: key) {
            return String(doubleValue)
        } else {
            return nil
        }
    }
}

struct AppData: Codable {
    let rentals: [Rental]
    let lenses: [Lens]
    let inventory: [InventoryItem]
}

struct LensGroup: Identifiable {
    let id = UUID()
    let manufacturer: String
    let series: [LensSeries]
}

struct LensSeries: Identifiable {
    let id = UUID()
    let name: String
    let lenses: [Lens]
}

enum DataLoadingState: Equatable {
    case idle
    case loading
    case loaded
    case error(String)
}

enum ActiveTab: Equatable {
    case rentalView
    case allLenses
    case favorites
}
