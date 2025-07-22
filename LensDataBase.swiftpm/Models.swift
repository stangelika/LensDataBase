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
    let lens_format: String?

    enum CodingKeys: String, CodingKey {
        case id, display_name, manufacturer, lens_name, format,
             focal_length, aperture, close_focus_in, close_focus_cm,
             image_circle, length, front_diameter, squeeze_factor,
             lens_format
    }

    init(id: String, display_name: String, manufacturer: String, lens_name: String, format: String, focal_length: String, aperture: String, close_focus_in: String, close_focus_cm: String, image_circle: String, length: String, front_diameter: String, squeeze_factor: String?, lens_format: String?) {
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
        self.lens_format = lens_format
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

enum FocalCategory: String, CaseIterable, Identifiable {
    case all, ultraWide, wide, standard, tele, superTele

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .all: return "All"
        case .ultraWide: return "Ultra Wide (≤12mm)"
        case .wide: return "Wide (13–35mm)"
        case .standard: return "Standard (36–70mm)"
        case .tele: return "Tele (71–180mm)"
        case .superTele: return "Super Tele (181mm + )"
        }
    }

    func contains(focal: Double?) -> Bool {
        guard let f = focal else { return false }
        switch self {
        case .all: return true
        case .ultraWide: return f <= 12
        case .wide: return (13...35).contains(f)
        case .standard: return (36...70).contains(f)
        case .tele: return (71...180).contains(f)
        case .superTele: return f > 180
        }
    }
}

extension Lens {
    var mainFocalValue: Double? {
        let numbers = focal_length
            .components(separatedBy: CharacterSet(charactersIn: " - – "))
            .compactMap { Double($0.filter("0123456789.".contains)) }
        return numbers.first
    }
}

enum LensFormatCategory: String, CaseIterable, Identifiable {
    case s16
    case s35
    case ff
    case mft

    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .s16: return "S16"
        case .s35: return "S35 / S35+"
        case .ff:  return "FF / VV / LF / 65"
        case .mft: return "MFT / No Data / Unknown"
        }
    }
    func contains(lensFormat: String?) -> Bool {
        guard let format = lensFormat?.lowercased() else { return false }
        switch self {
        case .s16:
            return format.contains("s16")
        case .s35:
            return format.contains("s35")
        case .ff:
            return format.contains("ff") || format.contains("vv") || format.contains("lf") || format.contains("65")
        case .mft:
            return format.contains("mft") || format.contains("nodata") || format.contains("unknown") || format.isEmpty
        }
    }
}
