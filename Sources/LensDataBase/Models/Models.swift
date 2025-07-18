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
    
    /// Standard initializer for creating a Lens
    init(
        id: String,
        display_name: String,
        manufacturer: String,
        lens_name: String,
        format: String,
        focal_length: String,
        aperture: String,
        close_focus_in: String,
        close_focus_cm: String,
        image_circle: String,
        length: String,
        front_diameter: String,
        squeeze_factor: String? = nil
    ) {
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
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Process all fields using flexible decoder
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
    
    /// Flexible decoder that handles different JSON data types (String, Int, Double, Bool)
    private static func decodeFlexible(container: KeyedDecodingContainer<Lens.CodingKeys>, key: CodingKeys) throws -> String? {
        // Try to decode as string
        if let stringValue = try? container.decode(String.self, forKey: key) {
            return stringValue
        }
        // Try to decode as integer
        else if let intValue = try? container.decode(Int.self, forKey: key) {
            return String(intValue)
        }
        // Try to decode as double
        else if let doubleValue = try? container.decode(Double.self, forKey: key) {
            return String(doubleValue)
        }
        // Try to decode as boolean
        else if let boolValue = try? container.decode(Bool.self, forKey: key) {
            return boolValue ? "true" : "false"
        }
        // Return nil if all attempts fail
        else {
            return nil
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
    case projects
}
// MARK: - Project Model

/// Project model for organizing lenses and cameras into collections
struct Project: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var notes: String
    var date: Date
    var lensIDs: [String] // Array of lens IDs in this project
    var cameraIDs: [String] // Array of camera IDs in this project
    
    /// Creates an empty project with default values
    static func empty() -> Project {
        Project(
            id: UUID(),
            name: "New Project",
            notes: "",
            date: Date(),
            lensIDs: [],
            cameraIDs: []
        )
    }
}
