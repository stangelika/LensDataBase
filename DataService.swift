// DataService.swift

import Combine
import Foundation

// MARK: - Сетевой сервис для загрузки данных из API

// Сервис для выполнения сетевых запросов к Google Apps Script API
class NetworkService {
    // Синглтон для глобального доступа к сетевому сервису
    static let shared = NetworkService()

    // URL эндпоинта для получения данных о линзах
    private let LENS_DATA_URL = "https://script.google.com/macros/s/AKfycbzDzKQ3AU6ynZuPjET0NWqYMlDXMt5UKVPBOq9g7XurJKPoulWuPVVIl9U8eq_nSCG6/exec"
    // URL эндпоинта для получения данных о камерах
    private let CAMERA_DATA_URL = "https://script.google.com/macros/s/AKfycbz-2rLDrwQ7DPD3nOm7iGTvCISfIYggOVob2F43pgjR2UG3diztAaig6wO737m_Rh3GJw/exec"

    // Асинхронная загрузка данных о линзах из API
    func fetchLensData() -> AnyPublisher<AppData, Error> {
        // Проверяем валидность URL
        guard let url = URL(string: LENS_DATA_URL) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        // Выполняем сетевой запрос с обработкой ответа
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response -> Data in
                // Проверяем статус HTTP ответа
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            // Декодируем JSON в модель AppData
            .decode(type: AppData.self, decoder: JSONDecoder())
            // Переключаемся на главный поток для обновления UI
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    // Асинхронная загрузка данных о камерах из API
    func fetchCameraData() -> AnyPublisher<CameraApiResponse, Error> {
        // Проверяем валидность URL
        guard let url = URL(string: CAMERA_DATA_URL) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        // Выполняем сетевой запрос с обработкой ответа
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response -> Data in
                // Проверяем статус HTTP ответа  
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            // Декодируем JSON в модель CameraApiResponse
            .decode(type: CameraApiResponse.self, decoder: JSONDecoder())
            // Переключаемся на главный поток для обновления UI
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

// MARK: - Менеджер данных приложения

// Центральный менеджер состояния приложения, управляющий всеми данными
class DataManager: ObservableObject {
    // Основные данные приложения, загруженные из API или локального JSON
    @Published var appData: AppData?
    // Текущее состояние загрузки данных для отображения индикаторов
    @Published var loadingState: DataLoadingState = .idle
    // Список доступных линз после фильтрации по инвентарю
    @Published var availableLenses: [Lens] = []

    // Данные о камерах из отдельного API
    @Published var cameras: [Camera] = []
    // Форматы записи для камер
    @Published var formats: [RecordingFormat] = []

    // UI состояние: активная вкладка в главном интерфейсе
    @Published var activeTab: ActiveTab = .allLenses
    // ID выбранной компании проката для фильтрации
    @Published var selectedRentalId: String = ""

    // Функциональность избранного: множество ID избранных линз
    @Published var favoriteLenses = Set<String>()
    // Функциональность сравнения: множество ID линз для сравнения (макс. 4)
    @Published var comparisonSet = Set<String>()
    

    // Кешированный список избранных линз для быстрого доступа в UI
    @Published var favoriteLensesList: [Lens] = []

    // Контейнер для хранения Combine подписок
    private var cancellables = Set<AnyCancellable>()
    // Ключ для сохранения избранного в UserDefaults
    private let favoritesKey = "favoriteLenses"
    

    // Инициализатор: загружаем сохраненные данные при запуске
    init() {
        loadFavorites()
        
    }

    
    // MARK: - Управление избранными линзами

    // Обновление кешированного списка избранных линз для UI
    private func updateFavoriteLensesList() {
        favoriteLensesList = availableLenses
            .filter { favoriteLenses.contains($0.id) }
            .sorted { $0.display_name < $1.display_name }
    }

    // Сохранение избранных линз в UserDefaults
    private func saveFavorites() {
        let favoritesArray = Array(favoriteLenses)
        UserDefaults.standard.set(favoritesArray, forKey: favoritesKey)
    }

    // Загрузка сохраненных избранных линз из UserDefaults
    private func loadFavorites() {
        guard let favoritesArray = UserDefaults.standard.array(forKey: favoritesKey) as? [String] else { return }
        favoriteLenses = Set(favoritesArray)
    }

    // Проверка, является ли линза избранной
    func isFavorite(lens: Lens) -> Bool {
        favoriteLenses.contains(lens.id)
    }

    // Переключение статуса избранного для линзы
    func toggleFavorite(lens: Lens) {
        if isFavorite(lens: lens) {
            favoriteLenses.remove(lens.id)
        } else {
            favoriteLenses.insert(lens.id)
        }
        saveFavorites()
        updateFavoriteLensesList()
    }

    // MARK: - Управление сравнением линз

    // Проверка, находится ли линза в списке сравнения
    func isInComparison(lens: Lens) -> Bool { comparisonSet.contains(lens.id) }

    // Переключение статуса сравнения для линзы (максимум 4 линзы)
    func toggleComparison(lens: Lens) {
        // Проверяем лимит: если линза не в сравнении и уже 4 линзы, выходим
        if !isInComparison(lens: lens), comparisonSet.count >= 4 { return }
        // Переключаем статус линзы в сравнении
        if isInComparison(lens: lens) {
            comparisonSet.remove(lens.id)
        } else {
            comparisonSet.insert(lens.id)
        }
    }

    // Очистка всех линз из сравнения
    func clearComparison() {
        comparisonSet.removeAll()
    }

    // MARK: - Загрузка данных

    // Основной метод загрузки данных из локальных JSON файлов
    func loadData() {
        // Предотвращаем повторную загрузку
        guard loadingState == .idle else { return }
        loadingState = .loading

        // Создаем паблишеры для загрузки данных линз и камер параллельно
        let lensPublisher = loadLocalJSON(from: "LENSDATA") as AnyPublisher<AppData, Error>
        let cameraPublisher = loadLocalJSON(from: "CAMERADATA") as AnyPublisher<CameraApiResponse, Error>

        // Объединяем оба запроса и обрабатываем результат
        Publishers.Zip(lensPublisher, cameraPublisher)
            .sink(receiveCompletion: { [weak self] completion in
                // Обрабатываем ошибки загрузки
                if case let .failure(error) = completion {
                    self?.loadingState = .error(error.localizedDescription)
                }
            }, receiveValue: { [weak self] appData, cameraData in
                guard let self else { return }
                // Сохраняем загруженные данные
                self.appData = appData
                collectAvailableLenses()
                cameras = cameraData.camera.sorted { $0.manufacturer < $1.manufacturer }
                formats = cameraData.formats
                loadingState = .loaded

                // Обновляем список избранных после загрузки данных
                updateFavoriteLensesList()
                print("✅ Локальные данные успешно загружены!")
            })
            .store(in: &cancellables)
    }

    // Обновление данных с сервера через API
    func refreshDataFromAPI() {
        print("Начинаем обновление данных с сервера...")
        loadingState = .loading

        // Последовательная загрузка данных линз, затем камер
        NetworkService.shared.fetchLensData()
            .flatMap { [weak self] appData -> AnyPublisher<CameraApiResponse, Error> in
                // Сохраняем данные линз и переходим к загрузке камер
                self?.appData = appData
                self?.collectAvailableLenses()
                return NetworkService.shared.fetchCameraData()
            }
            .sink(receiveCompletion: { [weak self] completion in
                // Обрабатываем ошибки сетевого запроса
                if case let .failure(error) = completion {
                    self?.loadingState = .error(error.localizedDescription)
                    print("❌ Ошибка при обновлении данных с сервера: \(error)")
                }
            }, receiveValue: { [weak self] cameraResponse in
                // Сохраняем данные камер и завершаем загрузку
                self?.cameras = cameraResponse.camera.sorted { $0.manufacturer < $1.manufacturer }
                self?.formats = cameraResponse.formats
                self?.loadingState = .loaded
                print("✅ Данные с сервера успешно обновлены!")
            })
            .store(in: &cancellables)
    }

    // Универсальный метод загрузки JSON файлов из Bundle
    private func loadLocalJSON<T: Decodable>(from fileName: String) -> AnyPublisher<T, Error> {
        // Проверяем наличие файла в Bundle
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            return Fail(error: URLError(.fileDoesNotExist)).eraseToAnyPublisher()
        }

        // Загружаем и декодируем JSON файл
        return Just(url)
            .tryMap { try Data(contentsOf: $0) }
            .decode(type: T.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    // MARK: - Вспомогательные функции

    // Формирование списка доступных линз на основе инвентаря компаний
    private func collectAvailableLenses() {
        guard let appData else { return }

        // Собираем все ID линз из инвентаря всех компаний
        let lensIds = Set(appData.inventory.values.flatMap { $0.map(\.lens_id) })
        // Фильтруем общий список линз по доступным ID
        availableLenses = appData.lenses.filter { lensIds.contains($0.id) }
    }

    // Группировка линз по производителям и сериям для организованного отображения
    func groupLenses(forRental rentalId: String? = nil) -> [LensGroup] {
        // Выбираем линзы: либо для конкретной компании, либо все доступные
        let lenses = rentalId != nil ? lensesForRental(rentalId!) : availableLenses

        // Группируем по нормализованным названиям производителей
        let normalizedManufacturers = lenses.reduce(into: [String: [Lens]]()) { result, lens in
            let normalized = normalizeName(lens.manufacturer)
            result[normalized, default: []].append(lens)
        }

        // Создаем группы производителей с сериями
        return normalizedManufacturers.map { manufacturerKey, lenses in
            let originalManufacturer = lenses.first?.manufacturer ?? manufacturerKey

            // Группируем линзы производителя по сериям
            let normalizedSeries = lenses.reduce(into: [String: [Lens]]()) { result, lens in
                let normalized = normalizeName(lens.lens_name)
                result[normalized, default: []].append(lens)
            }

            // Создаем серии для данного производителя
            let series = normalizedSeries.map { seriesKey, lenses in
                let originalSeriesName = lenses.first?.lens_name ?? seriesKey
                return LensSeries(name: originalSeriesName, lenses: lenses)
            }.sorted { $0.name < $1.name }

            return LensGroup(manufacturer: originalManufacturer, series: series.sorted { $0.name < $1.name })
        }.sorted { $0.manufacturer < $1.manufacturer }
    }

    // Получение линз для конкретной компании проката
    private func lensesForRental(_ rentalId: String) -> [Lens] {
        guard
            let appData,
            let inventory = appData.inventory[rentalId] else { return [] }

        // Извлекаем ID линз из инвентаря компании
        let lensIds = inventory.map(\.lens_id)
        // Фильтруем общий список линз по ID инвентаря
        return appData.lenses.filter { lensIds.contains($0.id) }
    }

    // Нормализация названий для корректной группировки
    private func normalizeName(_ str: String) -> String {
        str
            .lowercased()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: "series", with: "", options: .caseInsensitive)
            .replacingOccurrences(of: "edition", with: "", options: .caseInsensitive)
    }

    // Поиск детальной информации о линзе по ID
    func lensDetails(for id: String) -> Lens? {
        appData?.lenses.first { $0.id == id }
    }

    // Поиск компаний проката, у которых есть конкретная линза
    func rentalsForLens(_ lensId: String) -> [Rental] {
        guard let appData else { return [] }

        // Ищем компании, в инвентаре которых есть данная линза
        return appData.inventory.compactMap { rentalId, items in
            if items.contains(where: { $0.lens_id == lensId }) {
                return appData.rentals.first { $0.id == rentalId }
            }
            return nil
        }.compactMap { $0 }
    }
}
