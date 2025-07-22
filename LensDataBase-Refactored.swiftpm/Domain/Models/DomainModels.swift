import Foundation

// MARK: - Core Domain Protocols

/// Protocol for all domain entities
protocol DomainEntity: Codable, Identifiable, Hashable {
    var id: String { get }
}

/// Protocol for entities with display names
protocol NamedEntity: DomainEntity {
    var displayName: String { get }
}

/// Protocol for filterable entities
protocol FilterableEntity {
    func matches(filter: String) -> Bool
}

// MARK: - Lens Domain Model

struct Lens: DomainEntity, NamedEntity, FilterableEntity {
    let id: String
    let displayName: String
    let manufacturer: String
    let model: String
    let specifications: LensSpecifications
    let physicalProperties: PhysicalProperties
    let compatibility: LensCompatibility
    
    var format: String { specifications.format }
    var focalLength: String { specifications.focalLength }
    var aperture: String { specifications.aperture }
    
    func matches(filter: String) -> Bool {
        let searchableText = "\(displayName) \(manufacturer) \(model) \(specifications.format)"
        return searchableText.localizedCaseInsensitiveContains(filter)
    }
}

struct LensSpecifications: Codable, Hashable {
    let format: String
    let focalLength: String
    let aperture: String
    let closeFocusDistance: CloseFocusDistance
    let imageCircle: String?
    let squeezeFactor: String?
    
    var focalLengthNumeric: Double? {
        FocalLengthParser.parseMainValue(from: focalLength)
    }
}

struct CloseFocusDistance: Codable, Hashable {
    let inches: String
    let centimeters: String
}

struct PhysicalProperties: Codable, Hashable {
    let length: String
    let frontDiameter: String
    let weight: String?
}

struct LensCompatibility: Codable, Hashable {
    let mount: String?
    let supportedFormats: [String]
    let recommendedCameras: [String]
}

// MARK: - Camera Domain Model

struct Camera: DomainEntity, NamedEntity {
    let id: String
    let displayName: String
    let manufacturer: String
    let model: String
    let sensor: SensorSpecifications
    let supportedFormats: [RecordingFormat]
    
    func isCompatible(with lens: Lens) -> Bool {
        // Implementation for camera-lens compatibility check
        supportedFormats.contains { format in
            format.isCompatible(with: lens.specifications.format)
        }
    }
}

struct SensorSpecifications: Codable, Hashable {
    let type: String
    let width: String
    let height: String
    let imageCircle: String
}

struct RecordingFormat: DomainEntity {
    let id: String
    let name: String
    let width: String
    let height: String
    let imageCircle: String
    
    func isCompatible(with lensFormat: String) -> Bool {
        // Implementation for format compatibility
        lensFormat.lowercased().contains(name.lowercased())
    }
}

// MARK: - Rental Domain Model

struct Rental: DomainEntity, NamedEntity {
    let id: String
    let displayName: String
    let contactInformation: ContactInformation
    let location: Location?
    let inventory: [String] // Lens IDs
}

struct ContactInformation: Codable, Hashable {
    let phone: String
    let website: String
    let email: String?
}

struct Location: Codable, Hashable {
    let address: String
    let city: String?
    let country: String?
}

// MARK: - Utility Types

enum FocalLengthCategory: String, CaseIterable, Identifiable {
    case all = "all"
    case ultraWide = "ultraWide"
    case wide = "wide"
    case standard = "standard"
    case telephoto = "telephoto"
    case superTelephoto = "superTelephoto"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .all: return "All"
        case .ultraWide: return "Ultra Wide (≤12mm)"
        case .wide: return "Wide (13–35mm)"
        case .standard: return "Standard (36–70mm)"
        case .telephoto: return "Telephoto (71–180mm)"
        case .superTelephoto: return "Super Telephoto (181mm+)"
        }
    }
    
    func contains(_ focalLength: Double?) -> Bool {
        guard let focal = focalLength else { return false }
        switch self {
        case .all: return true
        case .ultraWide: return focal <= 12
        case .wide: return (13...35).contains(focal)
        case .standard: return (36...70).contains(focal)
        case .telephoto: return (71...180).contains(focal)
        case .superTelephoto: return focal > 180
        }
    }
}

enum LensFormat: String, CaseIterable, Identifiable {
    case s16 = "S16"
    case s35 = "S35"
    case fullFrame = "FF"
    case vistaVision = "VV"
    case largeFormat = "LF"
    case microFourThirds = "MFT"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .s16: return "Super 16"
        case .s35: return "Super 35"
        case .fullFrame: return "Full Frame"
        case .vistaVision: return "Vista Vision"
        case .largeFormat: return "Large Format"
        case .microFourThirds: return "Micro Four Thirds"
        }
    }
}

// MARK: - Utility Classes

struct FocalLengthParser {
    static func parseMainValue(from focalLength: String) -> Double? {
        let numbers = focalLength
            .components(separatedBy: CharacterSet(charactersIn: " -–"))
            .compactMap { component in
                Double(component.filter("0123456789.".contains))
            }
        return numbers.first
    }
}