import Foundation

// MARK: - Модели для API v2 (Камеры и Форматы)

struct CameraApiResponse: Codable {
    let camera: [Camera]
    let formats: [RecordingFormat]
}

// ИСПРАВЛЕННАЯ СТРУКТУРА CAMERA
struct Camera: Codable, Identifiable, Hashable {
    let id: String // БЫЛ Int, СТАЛ String
    let manufacturer: String
    let model: String
    let sensor: String
    let sensorWidth: String // Названия свойств оставляем для удобства
    let sensorHeight: String
    let imageCircle: String

    // Добавляем CodingKeys для связи с JSON
    private enum CodingKeys: String, CodingKey {
        case id, manufacturer, model, sensor
        case sensorWidth = "sensorwidth"
        case sensorHeight = "sensorheight"
        case imageCircle = "imagecircle"
    }
}

// ИСПРАВЛЕННАЯ СТРУКТУРА RECORDINGFORMAT
struct RecordingFormat: Codable, Identifiable, Hashable {
    let id: String // БЫЛ Int, СТАЛ String
    let cameraId: String // БЫЛ Int, СТАЛ String
    let manufacturer: String
    let model: String
    let sensorWidth: String
    let sensorHeight: String
    let recordingFormat: String
    let recordingWidth: String
    let recordingHeight: String
    let recordingImageCircle: String

    // Добавляем CodingKeys для связи с JSON
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

// MARK: - Модели данных

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

        // Обрабатываем все поля с помощью универсального декодера
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

    // Универсальный метод для декодирования любых полей
    private static func decodeFlexible(container: KeyedDecodingContainer<Lens.CodingKeys>, key: CodingKeys) throws -> String? {
        // Пробуем декодировать как строку
        if let stringValue = try? container.decode(String.self, forKey: key) {
            stringValue
        }
        // Пробуем декодировать как целое число
        else if let intValue = try? container.decode(Int.self, forKey: key) {
            String(intValue)
        }
        // Пробуем декодировать как число с плавающей точкой
        else if let doubleValue = try? container.decode(Double.self, forKey: key) {
            String(doubleValue)
        }
        // Пробуем декодировать как булево значение
        else if let boolValue = try? container.decode(Bool.self, forKey: key) {
            boolValue ? "true" : "false"
        }
        // Если ничего не получилось, возвращаем nil
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

    // Кастомный инициализатор для обработки ошибок в массиве объективов
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        last_updated = try container.decode(String.self, forKey: .last_updated)
        rentals = try container.decode([Rental].self, forKey: .rentals)
        inventory = try container.decode([String: [InventoryItem]].self, forKey: .inventory)

        // Обрабатываем объективы с защитой от ошибок (ИСПРАВЛЕНО: let вместо var)
        let lensesArray = try container.decode([Lens].self, forKey: .lenses)

        // Фильтруем объективы с пустым ID
        lenses = lensesArray.filter { !$0.id.isEmpty }
    }
}

// MARK: - Группировка данных для UI

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

// MARK: - Состояния приложения (ИСПРАВЛЕНО: добавлено Equatable)

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

// MARK: - Модель для Проектов

struct Project: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var notes: String
    var date: Date
    var lensIDs: [String] // Массив ID объективов в этом проекте
    var cameraIDs: [String] // Массив ID камер в этом проекте

    // Статический метод для создания пустого проекта
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
