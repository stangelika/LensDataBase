// DataService_Version3.swift

import Foundation
import Combine

// ... (NetworkService без изменений) ...
class NetworkService {
    static let shared = NetworkService()
    
    private let LENS_DATA_URL = "https://script.google.com/macros/s/AKfycbzDzKQ3AU6ynZuPjET0NWqYMlDXMt5UKVPBOq9g7XurJKPoulWuPVVIl9U8eq_nSCG6/exec"
    private let CAMERA_DATA_URL = "https://script.google.com/macros/s/AKfycbz-2rLDrwQ7DPD3nOm7iGTvCISfIYggOVob2F43pgjR2UG3diztAaig6wO737m_Rh3GJw/exec"
    
    func fetchLensData() -> AnyPublisher<AppData, Error> {
        guard let url = URL(string: LENS_DATA_URL) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: AppData.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func fetchCameraData() -> AnyPublisher<CameraApiResponse, Error> {
        guard let url = URL(string: CAMERA_DATA_URL) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: CameraApiResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}


// MARK: - Менеджер данных (ОБНОВЛЕН)
class DataManager: ObservableObject {
    @Published var appData: AppData?
    @Published var loadingState: DataLoadingState = .idle
    @Published var availableLenses: [Lens] = []
    
    @Published var cameras: [Camera] = []
    @Published var formats: [RecordingFormat] = []
    
    @Published var activeTab: ActiveTab = .allLenses
    @Published var selectedRentalId: String = ""
    
    // Свойства для новых функций
    @Published var favoriteLenses = Set<String>()
    @Published var comparisonSet = Set<String>()
    @Published var projects: [Project] = [] // <-- НОВЫЙ МАССИВ ДЛЯ ПРОЕКТОВ
    
    @Published var favoriteLensesList: [Lens] = []
    
    private var cancellables = Set<AnyCancellable>()
    private let favoritesKey = "favoriteLenses"
    private let projectsKey = "userProjects" // <-- НОВЫЙ КЛЮЧ ДЛЯ ХРАНЕНИЯ

    init() {
        loadFavorites()
        loadProjects() // <-- ЗАГРУЖАЕМ ПРОЕКТЫ ПРИ СТАРТЕ
    }
    
    // MARK: - Projects Logic
    
    func addProject() {
        let newProject = Project.empty()
        projects.append(newProject)
        saveProjects()
    }
    
    func deleteProject(at offsets: IndexSet) {
        projects.remove(atOffsets: offsets)
        saveProjects()
    }
    
    func updateProject(_ project: Project) {
        guard let index = projects.firstIndex(where: { $0.id == project.id }) else { return }
        projects[index] = project
        saveProjects()
    }
    
    private func saveProjects() {
        do {
            let data = try JSONEncoder().encode(projects)
            UserDefaults.standard.set(data, forKey: projectsKey)
        } catch {
            print("❌ Failed to save projects: \(error)")
        }
    }
    
    private func loadProjects() {
        guard let data = UserDefaults.standard.data(forKey: projectsKey) else { return }
        do {
            projects = try JSONDecoder().decode([Project].self, from: data)
        } catch {
            print("❌ Failed to load projects: \(error)")
        }
    }
    
    // MARK: - Favorites Logic
    
    private func updateFavoriteLensesList() {
        favoriteLensesList = availableLenses
            .filter { favoriteLenses.contains($0.id) }
            .sorted { $0.display_name < $1.display_name }
    }
    
    private func saveFavorites() {
        let favoritesArray = Array(favoriteLenses)
        UserDefaults.standard.set(favoritesArray, forKey: favoritesKey)
    }

    private func loadFavorites() {
        guard let favoritesArray = UserDefaults.standard.array(forKey: favoritesKey) as? [String] else { return }
        self.favoriteLenses = Set(favoritesArray)
    }

    func isFavorite(lens: Lens) -> Bool {
        return favoriteLenses.contains(lens.id)
    }

    func toggleFavorite(lens: Lens) {
        if isFavorite(lens: lens) {
            favoriteLenses.remove(lens.id)
        } else {
            favoriteLenses.insert(lens.id)
        }
        saveFavorites()
        updateFavoriteLensesList()
    }
    
    // MARK: - Comparison Logic
    
    func isInComparison(lens: Lens) -> Bool { return comparisonSet.contains(lens.id) }

    func toggleComparison(lens: Lens) {
        if !isInComparison(lens: lens) && comparisonSet.count >= 4 { return }
        if isInComparison(lens: lens) {
            comparisonSet.remove(lens.id)
        } else {
            comparisonSet.insert(lens.id)
        }
    }

    func clearComparison() {
        comparisonSet.removeAll()
    }
    
    // MARK: - Data Loading

    func loadData() {
        guard loadingState == .idle else { return }
        loadingState = .loading
        
        let lensPublisher = loadLocalJSON(from: "LENSDATA") as AnyPublisher<AppData, Error>
        let cameraPublisher = loadLocalJSON(from: "CAMERADATA") as AnyPublisher<CameraApiResponse, Error>

        Publishers.Zip(lensPublisher, cameraPublisher)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.loadingState = .error(error.localizedDescription)
                }
            }, receiveValue: { [weak self] (appData, cameraData) in
                guard let self = self else { return }
                self.appData = appData
                self.collectAvailableLenses()
                self.cameras = cameraData.camera.sorted { $0.manufacturer < $1.manufacturer }
                self.formats = cameraData.formats
                self.loadingState = .loaded
                
                self.updateFavoriteLensesList()
                print("✅ Локальные данные успешно загружены!")
            })
            .store(in: &cancellables)
    }

    func refreshDataFromAPI() {
        print("Начинаем обновление данных с сервера...")
        loadingState = .loading
        
        NetworkService.shared.fetchLensData()
            .flatMap { [weak self] appData -> AnyPublisher<CameraApiResponse, Error> in
                self?.appData = appData
                self?.collectAvailableLenses()
                return NetworkService.shared.fetchCameraData()
            }
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.loadingState = .error(error.localizedDescription)
                    print("❌ Ошибка при обновлении данных с сервера: \(error)")
                }
            }, receiveValue: { [weak self] cameraResponse in
                self?.cameras = cameraResponse.camera.sorted { $0.manufacturer < $1.manufacturer }
                self?.formats = cameraResponse.formats
                self?.loadingState = .loaded
                print("✅ Данные с сервера успешно обновлены!")
            })
            .store(in: &cancellables)
    }

    private func loadLocalJSON<T: Decodable>(from fileName: String) -> AnyPublisher<T, Error> {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            return Fail(error: URLError(.fileDoesNotExist)).eraseToAnyPublisher()
        }
        
        return Just(url)
            .tryMap { try Data(contentsOf: $0) }
            .decode(type: T.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Helper Functions
    
    private func collectAvailableLenses() {
        guard let appData = appData else { return }
        
        let lensIds = Set(appData.inventory.values.flatMap { $0.map { $0.lens_id } })
        availableLenses = appData.lenses.filter { lensIds.contains($0.id) }
    }
    
    func groupLenses(forRental rentalId: String? = nil) -> [LensGroup] {
        let lenses = rentalId != nil ? lensesForRental(rentalId!) : availableLenses
        
        let normalizedManufacturers = lenses.reduce(into: [String: [Lens]]()) { result, lens in
            let normalized = normalizeName(lens.manufacturer)
            result[normalized, default: []].append(lens)
        }
        
        return normalizedManufacturers.map { manufacturerKey, lenses in
            let originalManufacturer = lenses.first?.manufacturer ?? manufacturerKey
            
            let normalizedSeries = lenses.reduce(into: [String: [Lens]]()) { result, lens in
                let normalized = normalizeName(lens.lens_name)
                result[normalized, default: []].append(lens)
            }
            
            let series = normalizedSeries.map { seriesKey, lenses in
                let originalSeriesName = lenses.first?.lens_name ?? seriesKey
                return LensSeries(name: originalSeriesName, lenses: lenses)
            }.sorted { $0.name < $1.name }
            
            return LensGroup(manufacturer: originalManufacturer, series: series.sorted { $0.name < $1.name })
        }.sorted { $0.manufacturer < $1.manufacturer }
    }
    
    private func lensesForRental(_ rentalId: String) -> [Lens] {
        guard let appData = appData,
              let inventory = appData.inventory[rentalId] else { return [] }
        
        let lensIds = inventory.map { $0.lens_id }
        return appData.lenses.filter { lensIds.contains($0.id) }
    }
    
    private func normalizeName(_ str: String) -> String {
        return str
            .lowercased()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: "series", with: "", options: .caseInsensitive)
            .replacingOccurrences(of: "edition", with: "", options: .caseInsensitive)
    }
    
    func lensDetails(for id: String) -> Lens? {
        return appData?.lenses.first { $0.id == id }
    }
    
    func rentalsForLens(_ lensId: String) -> [Rental] {
        guard let appData = appData else { return [] }
        
        return appData.inventory.compactMap { rentalId, items in
            if items.contains(where: { $0.lens_id == lensId }) {
                return appData.rentals.first { $0.id == rentalId }
            }
            return nil
        }.compactMap { $0 }
    }
}