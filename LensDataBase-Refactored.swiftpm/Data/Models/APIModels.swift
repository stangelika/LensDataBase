import Foundation

// MARK: - API Response Models

struct APIResponse: Codable {
    let success: Bool
    let database: APIDatabase
}

struct APIDatabase: Codable {
    let rentals: [APIRental]
    let lenses: [APILens]
    let inventory: [APIInventoryItem]
}

struct APIRental: Codable {
    let id: String
    let name: String
    let address: String
    let phone: String
    let website: String
}

struct APILens: Codable {
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
    
    // Flexible decoding for various data types
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try Self.decodeFlexible(container: container, key: .id) ?? ""
        display_name = try Self.decodeFlexible(container: container, key: .display_name) ?? ""
        manufacturer = try Self.decodeFlexible(container: container, key: .manufacturer) ?? ""
        lens_name = try Self.decodeFlexible(container: container, key: .lens_name) ?? ""
        format = try Self.decodeFlexible(container: container, key: .format) ?? ""
        focal_length = try Self.decodeFlexible(container: container, key: .focal_length) ?? ""
        aperture = try Self.decodeFlexible(container: container, key: .aperture) ?? ""
        close_focus_in = try Self.decodeFlexible(container: container, key: .close_focus_in) ?? ""
        close_focus_cm = try Self.decodeFlexible(container: container, key: .close_focus_cm) ?? ""
        image_circle = try Self.decodeFlexible(container: container, key: .image_circle) ?? ""
        length = try Self.decodeFlexible(container: container, key: .length) ?? ""
        front_diameter = try Self.decodeFlexible(container: container, key: .front_diameter) ?? ""
        squeeze_factor = try? Self.decodeFlexible(container: container, key: .squeeze_factor)
        lens_format = try? Self.decodeFlexible(container: container, key: .lens_format)
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
        }
        return nil
    }
}

struct APIInventoryItem: Codable {
    let id: String
    let rental_id: String
    let lens_id: String
    let display_name: String?
    let notes: String?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try Self.decodeFlexible(container: container, key: .id) ?? ""
        rental_id = try Self.decodeFlexible(container: container, key: .rental_id) ?? ""
        lens_id = try Self.decodeFlexible(container: container, key: .lens_id) ?? ""
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
        }
        return nil
    }
}

struct APICameraResponse: Codable {
    let camera: [APICamera]
    let formats: [APIRecordingFormat]
}

struct APICamera: Codable {
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

struct APIRecordingFormat: Codable {
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

// MARK: - Mappers

struct DomainMapper {
    static func mapToDomain(apiLens: APILens) -> Lens {
        Lens(
            id: apiLens.id,
            displayName: apiLens.display_name,
            manufacturer: apiLens.manufacturer,
            model: apiLens.lens_name,
            specifications: LensSpecifications(
                format: apiLens.format,
                focalLength: apiLens.focal_length,
                aperture: apiLens.aperture,
                closeFocusDistance: CloseFocusDistance(
                    inches: apiLens.close_focus_in,
                    centimeters: apiLens.close_focus_cm
                ),
                imageCircle: apiLens.image_circle.isEmpty ? nil : apiLens.image_circle,
                squeezeFactor: apiLens.squeeze_factor
            ),
            physicalProperties: PhysicalProperties(
                length: apiLens.length,
                frontDiameter: apiLens.front_diameter,
                weight: nil // Not available in API
            ),
            compatibility: LensCompatibility(
                mount: nil, // Not available in API
                supportedFormats: [apiLens.format],
                recommendedCameras: [] // Would need separate mapping
            )
        )
    }
    
    static func mapToDomain(apiCamera: APICamera, formats: [APIRecordingFormat]) -> Camera {
        let cameraFormats = formats
            .filter { $0.cameraId == apiCamera.id }
            .map { format in
                RecordingFormat(
                    id: format.id,
                    name: format.recordingFormat,
                    width: format.recordingWidth,
                    height: format.recordingHeight,
                    imageCircle: format.recordingImageCircle
                )
            }
        
        return Camera(
            id: apiCamera.id,
            displayName: "\(apiCamera.manufacturer) \(apiCamera.model)",
            manufacturer: apiCamera.manufacturer,
            model: apiCamera.model,
            sensor: SensorSpecifications(
                type: apiCamera.sensor,
                width: apiCamera.sensorWidth,
                height: apiCamera.sensorHeight,
                imageCircle: apiCamera.imageCircle
            ),
            supportedFormats: cameraFormats
        )
    }
    
    static func mapToDomain(apiRental: APIRental, inventory: [APIInventoryItem]) -> Rental {
        let rentalInventory = inventory
            .filter { $0.rental_id == apiRental.id }
            .map { $0.lens_id }
        
        return Rental(
            id: apiRental.id,
            displayName: apiRental.name,
            contactInformation: ContactInformation(
                phone: apiRental.phone,
                website: apiRental.website,
                email: nil
            ),
            location: Location(
                address: apiRental.address,
                city: nil,
                country: nil
            ),
            inventory: rentalInventory
        )
    }
}