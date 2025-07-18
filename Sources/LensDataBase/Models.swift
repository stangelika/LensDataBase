import Foundation

#if canImport(SwiftUI)
    import SwiftUI
#endif

// MARK: - API Models for Camera and Format Data

/// Response structure for camera API containing cameras and recording formats
struct CameraApiResponse: Codable {
    let camera: [Camera]
    let formats: [RecordingFormat]
}

/// Camera model representing a camera from the API
struct Camera: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let manufacturer: String
    let sensor: String
    let resolution: String
    let formats: [String]
    let lensmount: String
    let isSupported: Bool
    let maxRecordingFormat: String
    let sensorTypes: [String]
    let sensorSizes: [String]
    
    // API response keys
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case manufacturer
        case sensor
        case resolution
        case formats
        case lensmount
        case isSupported = "is_supported"
        case maxRecordingFormat = "max_recording_format"
        case sensorTypes = "sensor_types"
        case sensorSizes = "sensor_sizes"
    }
}

/// Recording format model
struct RecordingFormat: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let width: Int
    let height: Int
    let frameRate: String
    let bitRate: String
    let colorSpace: String
    let codec: String
    let fileSize: String
    let quality: String
    let isSupported: Bool
    
    // API response keys
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case width
        case height
        case frameRate = "frame_rate"
        case bitRate = "bit_rate"
        case colorSpace = "color_space"
        case codec
        case fileSize = "file_size"
        case quality
        case isSupported = "is_supported"
    }
}

/// Rental company model
struct Rental: Codable, Identifiable {
    let id: String
    let name: String
    let location: String
    let contact: String
    let website: String
    let email: String
    let phone: String
}

/// Core lens model
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
    let rearDiameter: String
    let weight: String
    let version: String
    let description: String
    let priceRange: String
    let website: String
    let imageUrl: String
    let group: String
    let rentals: [String]
    let avgRating: Double
    let compatibility: String
    let squeezeFactor: String
    
    // API response keys
    private enum CodingKeys: String, CodingKey {
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
        case rearDiameter = "rear_diameter"
        case weight
        case version
        case description
        case priceRange = "price_range"
        case website
        case imageUrl = "image_url"
        case group
        case rentals
        case avgRating = "avg_rating"
        case compatibility
        case squeezeFactor = "squeeze_factor"
    }
}

/// Inventory item model
struct InventoryItem: Codable {
    let id: String
    let rentalId: String
    let lensId: String
    let serialNumber: String
    let condition: String
    let isAvailable: Bool
    let dailyRate: String
    let weeklyRate: String
    let monthlyRate: String
    let notes: String
    
    // API response keys
    private enum CodingKeys: String, CodingKey {
        case id
        case rentalId = "rental_id"
        case lensId = "lens_id"
        case serialNumber = "serial_number"
        case condition
        case isAvailable = "is_available"
        case dailyRate = "daily_rate"
        case weeklyRate = "weekly_rate"
        case monthlyRate = "monthly_rate"
        case notes
    }
}

/// Main app data structure
struct AppData: Codable {
    let lenses: [Lens]
    let cameras: [Camera]
    let rentals: [Rental]
    let recordingFormats: [RecordingFormat]
    let inventory: [InventoryItem]
    
    // API response keys
    private enum CodingKeys: String, CodingKey {
        case lenses
        case cameras
        case rentals
        case recordingFormats = "recording_formats"
        case inventory
    }
}

/// Lens group model for organizing lenses
struct LensGroup: Identifiable {
    let id: String
    let name: String
    let lenses: [Lens]
}

/// Lens series model for organizing lenses by series
struct LensSeries: Identifiable {
    let id: String
    let name: String
    let manufacturer: String
    let lenses: [Lens]
}