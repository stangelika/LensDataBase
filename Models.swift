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
    
    enum CodingKeys: String, CodingKey {
        case id
        case display_name
        case manufacturer
        case lens_name
        case format
        case focal_length
        case aperture
        case close_focus_in
        case close_focus_cm
        case image_circle
        case length
        case front_diameter
        case squeeze_factor
    }
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
    }
    private static func decodeFlexible(container: KeyedDecodingContainer<Lens.CodingKeys>, key: CodingKeys) throws -> String? {
        if let stringValue = try? container.decode(String.self, forKey: key) {
            stringValue
        }
        else if let intValue = try? container.decode(Int.self, forKey: key) {
            String(intValue)
        }
        else if let doubleValue = try? container.decode(Double.self, forKey: key) {
            String(doubleValue)
        }
        else if let boolValue = try? container.decode(Bool.self, forKey: key) {
            boolValue ? "true": "false"
        }
        else {
            nil
        }

    }

}
struct InventoryItem: Codable {
    let lens_id: String
}
struct AppData: Codable {
    let last_updated: String

    let rentals: [Rental]

    let lenses: [Lens]

    let inventory: [String: [InventoryItem]]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        last_updated = try container.decode(String.self, forKey: .last_updated)
        rentals = try container.decode([Rental].self, forKey: .rentals)
        inventory = try container.decode([String: [InventoryItem]].self, forKey: .inventory)

        let lensesArray = try container.decode([Lens].self, forKey: .lenses)

        lenses = lensesArray.filter {
            !$0.id.isEmpty
        }

    }

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
    case updateView
    case favorites
    case projects
}
