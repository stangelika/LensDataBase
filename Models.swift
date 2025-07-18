import Foundation

// MARK: - Модели для API v2 (Камеры и Форматы)

// Ответ API для камер и форматов записи
struct CameraApiResponse: Codable {
    // Массив доступных камер
    let camera: [Camera]
    // Массив форматов записи для камер
    let formats: [RecordingFormat]
}

// Модель данных камеры
struct Camera: Codable, Identifiable, Hashable {
    // Уникальный идентификатор камеры
    let id: String // БЫЛ Int, СТАЛ String
    // Производитель камеры
    let manufacturer: String
    // Модель камеры
    let model: String
    // Тип сенсора
    let sensor: String
    // Ширина сенсора в миллиметрах
    let sensorWidth: String // Названия свойств оставляем для удобства
    // Высота сенсора в миллиметрах
    let sensorHeight: String
    // Диаметр изображения сенсора
    let imageCircle: String

    // Маппинг свойств Swift на ключи JSON API
    private enum CodingKeys: String, CodingKey {
        case id, manufacturer, model, sensor
        case sensorWidth = "sensorwidth"
        case sensorHeight = "sensorheight"
        case imageCircle = "imagecircle"
    }
}

// Модель формата записи камеры
struct RecordingFormat: Codable, Identifiable, Hashable {
    // Уникальный идентификатор формата
    let id: String // БЫЛ Int, СТАЛ String
    // Идентификатор связанной камеры
    let cameraId: String // БЫЛ Int, СТАЛ String
    // Производитель камеры
    let manufacturer: String
    // Модель камеры
    let model: String
    // Ширина сенсора
    let sensorWidth: String
    // Высота сенсора
    let sensorHeight: String
    // Формат записи (например, RAW, ProRes)
    let recordingFormat: String
    // Ширина записываемого изображения
    let recordingWidth: String
    // Высота записываемого изображения
    let recordingHeight: String
    // Круг изображения для записи
    let recordingImageCircle: String

    // Маппинг свойств Swift на ключи JSON API
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

// Модель компании проката оборудования
struct Rental: Codable, Identifiable {
    // Уникальный идентификатор компании
    let id: String
    // Название компании
    let name: String
    // Адрес компании
    let address: String
    // Телефон для связи
    let phone: String
    // Веб-сайт компании
    let website: String
}

// Модель объектива с полной технической информацией
struct Lens: Codable, Identifiable {
    // Уникальный идентификатор объектива
    let id: String
    // Отображаемое название для UI
    let display_name: String
    // Производитель объектива
    let manufacturer: String
    // Название модели объектива
    let lens_name: String
    // Формат съемки (35mm, S35, FF и т.д.)
    let format: String
    // Фокусное расстояние в миллиметрах
    let focal_length: String
    // Максимальная диафрагма
    let aperture: String
    // Минимальная дистанция фокуса в дюймах
    let close_focus_in: String
    // Минимальная дистанция фокуса в сантиметрах
    let close_focus_cm: String
    // Диаметр круга изображения
    let image_circle: String
    // Длина объектива
    let length: String
    // Диаметр передней линзы
    let front_diameter: String
    // Коэффициент сжатия для анаморфных объективов
    let squeeze_factor: String?

    // Маппинг ключей JSON на свойства модели
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

    // Кастомный инициализатор для гибкого декодирования типов данных из JSON
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Обрабатываем все поля с помощью универсального декодера для поддержки разных типов данных
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

    // Универсальный метод для декодирования полей разных типов в строки
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

// Модель элемента инвентаря - связывает объектив с компанией проката
struct InventoryItem: Codable {
    // Идентификатор объектива в системе
    let lens_id: String
}

// Основная модель данных приложения, получаемая из API
struct AppData: Codable {
    // Дата последнего обновления данных
    let last_updated: String
    // Массив компаний проката
    let rentals: [Rental]
    // Массив всех объективов в базе данных
    let lenses: [Lens]
    // Словарь инвентаря: ключ - ID компании, значение - массив объективов
    let inventory: [String: [InventoryItem]]

    // Кастомный инициализатор для обработки ошибок в массиве объективов
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Декодируем простые поля
        last_updated = try container.decode(String.self, forKey: .last_updated)
        rentals = try container.decode([Rental].self, forKey: .rentals)
        inventory = try container.decode([String: [InventoryItem]].self, forKey: .inventory)

        // Обрабатываем объективы с защитой от ошибок декодирования
        let lensesArray = try container.decode([Lens].self, forKey: .lenses)

        // Фильтруем объективы с пустым ID для предотвращения ошибок UI
        lenses = lensesArray.filter { !$0.id.isEmpty }
    }
}

// MARK: - Группировка данных для UI

// Группа объективов по производителю для организованного отображения
struct LensGroup: Identifiable {
    let id = UUID()
    // Название производителя
    let manufacturer: String
    // Массив серий объективов этого производителя
    let series: [LensSeries]
}

// Серия объективов одного производителя
struct LensSeries: Identifiable {
    let id = UUID()
    // Название серии
    let name: String
    // Объективы в данной серии
    let lenses: [Lens]
}

// MARK: - Состояния приложения

// Состояние загрузки данных для отображения прогресса пользователю
enum DataLoadingState: Equatable {
    case idle // Ожидание
    case loading // Процесс загрузки
    case loaded // Данные успешно загружены
    case error(String) // Ошибка с описанием
}

// Активная вкладка в главном интерфейсе приложения
enum ActiveTab: Equatable {
    case rentalView // Экран компаний проката
    case allLenses // Экран всех объективов
    case updateView // Экран настроек и обновлений
    case favorites // Экран избранных объективов
    case projects // Экран проектов
}

// MARK: - Модель для Проектов

// Модель проекта пользователя для сохранения наборов объективов и камер
struct Project: Codable, Identifiable, Equatable {
    // Уникальный идентификатор проекта
    let id: UUID
    // Название проекта
    var name: String
    // Заметки к проекту
    var notes: String
    // Дата создания/изменения проекта
    var date: Date
    // Массив ID объективов в этом проекте
    var lensIDs: [String] // Массив ID объективов в этом проекте
    // Массив ID камер в этом проекте
    var cameraIDs: [String] // Массив ID камер в этом проекте

    // Статический метод для создания нового пустого проекта
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
