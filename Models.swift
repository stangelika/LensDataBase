import Foundation

// MARK: - API Models for Camera and Format Data

/// Response structure for camera API containing cameras and recording formats
struct CameraApiResponse: Codable {
    let camera: [Camera]
    let formats: [RecordingFormat]
}

/// Camera model representing a camera system with sensor information
struct Camera: Codable, Identifiable, Hashable {
    let id: String
    let manufacturer: String
    let model: String
    let sensor: String
    let sensorWidth: String
    let sensorHeight: String
    let imageCircle: String

    /// Coding keys for JSON decoding
    private enum CodingKeys: String, CodingKey {
        case id, manufacturer, model, sensor
        case sensorWidth = "sensorwidth"
        case sensorHeight = "sensorheight"
        case imageCircle = "imagecircle"
    }
}

/// Recording format model representing different recording formats for cameras
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

    /// Coding keys for JSON decoding
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

// MARK: - Core Data Models

/// Rental service model representing a camera equipment rental company
struct Rental: Codable, Identifiable {
    let id: String
    let name: String
    let address: String
    let phone: String
    let website: String
}

/// Lens model representing a camera lens with flexible JSON decoding
struct Lens: Codable, Identifiable {
    let id: String
    let displayName: String
    let manufacturer: String
    let lensName: String
    let format: String
    let focalLength: String
    let aperture: String
    let closeFocusIn: String
    let closeFocusCm: String
    let imageCircle: String
    let length: String
    let frontDiameter: String
    let squeezeFactor: String?

    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
        case manufacturer
        case lensName = "lens_name"
        case format
        case focalLength = "focal_length"
        case aperture
        case closeFocusIn = "close_focus_in"
        case closeFocusCm = "close_focus_cm"
        case imageCircle = "image_circle"
        case length
        case frontDiameter = "front_diameter"
        case squeezeFactor = "squeeze_factor"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Process all fields using flexible decoder
        id = try Lens.decodeFlexible(container: container, key: .id) ?? ""
        displayName = try Lens.decodeFlexible(container: container, key: .displayName) ?? ""
        manufacturer = try Lens.decodeFlexible(container: container, key: .manufacturer) ?? ""
        lensName = try Lens.decodeFlexible(container: container, key: .lensName) ?? ""
        format = try Lens.decodeFlexible(container: container, key: .format) ?? ""
        focalLength = try Lens.decodeFlexible(container: container, key: .focalLength) ?? ""
        aperture = try Lens.decodeFlexible(container: container, key: .aperture) ?? ""
        closeFocusIn = try Lens.decodeFlexible(container: container, key: .closeFocusIn) ?? ""
        closeFocusCm = try Lens.decodeFlexible(container: container, key: .closeFocusCm) ?? ""
        imageCircle = try Lens.decodeFlexible(container: container, key: .imageCircle) ?? ""
        length = try Lens.decodeFlexible(container: container, key: .length) ?? ""
        frontDiameter = try Lens.decodeFlexible(container: container, key: .frontDiameter) ?? ""
        squeezeFactor = try Lens.decodeFlexible(container: container, key: .squeezeFactor)
    }

    /// Flexible decoder that handles different JSON data types (String, Int, Double, Bool)
    private static func decodeFlexible(
        container: KeyedDecodingContainer<Lens.CodingKeys>,
        key: CodingKeys) throws -> String? {
        // Try to decode as string
        if let stringValue = try? container.decode(String.self, forKey: key) {
            stringValue
        }
        // Try to decode as integer
        else if let intValue = try? container.decode(Int.self, forKey: key) {
            String(intValue)
        }
        // Try to decode as double
        else if let doubleValue = try? container.decode(Double.self, forKey: key) {
            String(doubleValue)
        }
        // Try to decode as boolean
        else if let boolValue = try? container.decode(Bool.self, forKey: key) {
            boolValue ? "true" : "false"
        }
        // Return nil if all attempts fail
        else {
            nil
        }
    }
}

/// Inventory item representing a lens available at a rental location
struct InventoryItem: Codable {
    let lens_id: String
}

/// Main application data container
struct AppData: Codable {
    let last_updated: String
    let rentals: [Rental]
    let lenses: [Lens]
    let inventory: [String: [InventoryItem]]

    /// Custom initializer to handle lens array parsing with error protection
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        last_updated = try container.decode(String.self, forKey: .last_updated)
        rentals = try container.decode([Rental].self, forKey: .rentals)
        inventory = try container.decode([String: [InventoryItem]].self, forKey: .inventory)

        // Process lenses with error protection
        let lensesArray = try container.decode([Lens].self, forKey: .lenses)

        // Filter out lenses with empty IDs
        lenses = lensesArray.filter { !$0.id.isEmpty }
    }
}

// MARK: - UI Data Structures

/// Grouped lenses by manufacturer for UI display
struct LensGroup: Identifiable {
    let id = UUID()
    let manufacturer: String
    let series: [LensSeries]
}

/// Grouped lenses by series within a manufacturer for UI display
struct LensSeries: Identifiable {
    let id = UUID()
    let name: String
    let lenses: [Lens]
}

// MARK: - Application State Enums

/// Data loading states for the application
enum DataLoadingState: Equatable {
    case idle
    case loading
    case loaded
    case error(String)
}

/// Active tabs in the application
enum ActiveTab: Equatable {
    case rentalView
    case allLenses
    case updateView
    case favorites
}
