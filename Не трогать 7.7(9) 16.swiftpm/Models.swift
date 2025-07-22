import Foundation

// MARK: - Модели для API v2 (Камеры и Форматы)

struct CameraApiResponse: Codable {
    let camera: [Camera]
    let formats: [RecordingFormat]
}

// MARK: - Camera Model
struct Camera: Codable, Identifiable, Hashable {
    let id: String // String instead of Int for API compatibility
    let manufacturer: String
    let model: String
    let sensor: String
    let sensorWidth: String
    let sensorHeight: String
    let imageCircle: String

    // CodingKeys for JSON mapping
    private enum CodingKeys: String, CodingKey {
        case id, manufacturer, model, sensor
        case sensorWidth = "sensorwidth"
        case sensorHeight = "sensorheight"
        case imageCircle = "imagecircle"
    }
}

// MARK: - Recording Format Model
struct RecordingFormat: Codable, Identifiable, Hashable {
    let id: String // String instead of Int for API compatibility
    let cameraId: String // String instead of Int for API compatibility
    let manufacturer: String
    let model: String
    let sensorWidth: String
    let sensorHeight: String
    let recordingFormat: String
    let recordingWidth: String
    let recordingHeight: String
    let recordingImageCircle: String

    // CodingKeys for JSON mapping
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


// MARK: - Lens Data Models
struct Rental: Codable, Identifiable {
    let id: String
    let name: String
    let address: String
    let phone: String
    let website: String
}

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
    let weight_g: String // Weight in grams
    let mount: String // Lens mount type
    
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
        case weight_g // Weight in grams
        case mount // Lens mount type
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Process all fields using universal decoder
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
        
        // Decode new fields with fallback values
        weight_g = (try? Lens.decodeFlexible(container: container, key: .weight_g)) ?? "N/A"
        mount = (try? Lens.decodeFlexible(container: container, key: .mount)) ?? "N/A"
    }
    
    // Universal method for decoding flexible field types
    private static func decodeFlexible(container: KeyedDecodingContainer<Lens.CodingKeys>, key: CodingKeys) throws -> String? {
        if let stringValue = try? container.decode(String.self, forKey: key) { return stringValue }
        else if let intValue = try? container.decode(Int.self, forKey: key) { return String(intValue) }
        else if let doubleValue = try? container.decode(Double.self, forKey: key) { return String(doubleValue) }
        else if let boolValue = try? container.decode(Bool.self, forKey: key) { return boolValue ? "true" : "false" }
        else { return nil }
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
        lenses = lensesArray.filter { !$0.id.isEmpty }
    }
}

// MARK: - UI Data Grouping
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

// MARK: - Application State
enum DataLoadingState: Equatable {
    case idle, loading, loaded, error(String)
}

enum ActiveTab: Equatable {
    case rentalView, allLenses, updateView, favorites, projects
}

// MARK: - Project Management Model

struct Project: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var notes: String
    var date: Date
    var lensIDs: [String]
    var cameraIDs: [String]
    
    // Custom initializer for creating new projects
    init(name: String) {
        self.id = UUID()
        self.name = name
        self.notes = "" // Default empty notes
        self.date = Date() // Default current date
        self.lensIDs = [] // Start with empty lens list
        self.cameraIDs = [] // Start with empty camera list
    }
    
    // Static method for creating empty projects
    static func empty() -> Project {
        return Project(name: "New Project")
    }
}

