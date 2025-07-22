import Foundation

// MARK: - Network Service Protocol

protocol NetworkServiceProtocol {
    func fetchLensData() async throws -> APIDatabase
    func fetchCameraData() async throws -> APICameraResponse
}

// MARK: - Network Service Implementation

final class NetworkService: NetworkServiceProtocol {
    private let urlSession: URLSession
    private let decoder: JSONDecoder
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
        self.decoder = JSONDecoder()
    }
    
    func fetchLensData() async throws -> APIDatabase {
        guard let url = URL(string: Constants.API.lensDataURL) else {
            throw NetworkError.invalidURL(Constants.API.lensDataURL)
        }
        
        do {
            let (data, response) = try await urlSession.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                throw NetworkError.httpError(httpResponse.statusCode)
            }
            
            let apiResponse = try decoder.decode(APIResponse.self, from: data)
            
            guard apiResponse.success else {
                throw NetworkError.apiError("API returned success: false")
            }
            
            return apiResponse.database
            
        } catch let error as DecodingError {
            throw NetworkError.decodingError(error.localizedDescription)
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.networkError(error.localizedDescription)
        }
    }
    
    func fetchCameraData() async throws -> APICameraResponse {
        // For now, load from local bundle
        // In a real implementation, this might also come from an API
        guard let url = Bundle.main.url(forResource: "CAMERADATA", withExtension: "json") else {
            throw NetworkError.localFileNotFound("CAMERADATA.json")
        }
        
        do {
            let data = try Data(contentsOf: url)
            return try decoder.decode(APICameraResponse.self, from: data)
        } catch let error as DecodingError {
            throw NetworkError.decodingError(error.localizedDescription)
        } catch {
            throw NetworkError.fileReadError(error.localizedDescription)
        }
    }
}

// MARK: - Network Errors

enum NetworkError: Error, LocalizedError {
    case invalidURL(String)
    case invalidResponse
    case httpError(Int)
    case networkError(String)
    case decodingError(String)
    case apiError(String)
    case localFileNotFound(String)
    case fileReadError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL(let url):
            return "Invalid URL: \(url)"
        case .invalidResponse:
            return "Invalid response received"
        case .httpError(let code):
            return "HTTP error with status code: \(code)"
        case .networkError(let message):
            return "Network error: \(message)"
        case .decodingError(let message):
            return "Data decoding error: \(message)"
        case .apiError(let message):
            return "API error: \(message)"
        case .localFileNotFound(let filename):
            return "Local file not found: \(filename)"
        case .fileReadError(let message):
            return "File read error: \(message)"
        }
    }
}

// MARK: - Constants

enum Constants {
    enum API {
        static let lensDataURL = "https://lksrental.site/api.php?action=all"
        static let timeout: TimeInterval = 30.0
    }
    
    enum Cache {
        static let lensDataKey = "cached_lens_data"
        static let cameraDataKey = "cached_camera_data"
        static let cacheExpirationInterval: TimeInterval = 3600 // 1 hour
    }
}

// MARK: - Cache Service

protocol CacheServiceProtocol {
    func getCachedData<T: Codable>(for key: String, type: T.Type) async -> T?
    func setCachedData<T: Codable>(_ data: T, for key: String) async
    func clearCache() async
    func isCacheValid(for key: String) async -> Bool
}

final class CacheService: CacheServiceProtocol {
    private let userDefaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    func getCachedData<T: Codable>(for key: String, type: T.Type) async -> T? {
        guard await isCacheValid(for: key),
              let data = userDefaults.data(forKey: key) else {
            return nil
        }
        
        return try? decoder.decode(type, from: data)
    }
    
    func setCachedData<T: Codable>(_ data: T, for key: String) async {
        guard let encoded = try? encoder.encode(data) else { return }
        
        userDefaults.set(encoded, forKey: key)
        userDefaults.set(Date(), forKey: "\(key)_timestamp")
    }
    
    func clearCache() async {
        let keys = [
            Constants.Cache.lensDataKey,
            Constants.Cache.cameraDataKey,
            "\(Constants.Cache.lensDataKey)_timestamp",
            "\(Constants.Cache.cameraDataKey)_timestamp"
        ]
        
        keys.forEach { userDefaults.removeObject(forKey: $0) }
    }
    
    func isCacheValid(for key: String) async -> Bool {
        guard let timestamp = userDefaults.object(forKey: "\(key)_timestamp") as? Date else {
            return false
        }
        
        return Date().timeIntervalSince(timestamp) < Constants.Cache.cacheExpirationInterval
    }
}

// MARK: - Network Service with Cache

final class CachedNetworkService: NetworkServiceProtocol {
    private let networkService: NetworkService
    private let cacheService: CacheServiceProtocol
    
    init(
        networkService: NetworkService = NetworkService(),
        cacheService: CacheServiceProtocol = CacheService()
    ) {
        self.networkService = networkService
        self.cacheService = cacheService
    }
    
    func fetchLensData() async throws -> APIDatabase {
        // Try cache first
        if let cachedData = await cacheService.getCachedData(
            for: Constants.Cache.lensDataKey,
            type: APIDatabase.self
        ) {
            return cachedData
        }
        
        // Fetch from network
        let data = try await networkService.fetchLensData()
        
        // Cache the result
        await cacheService.setCachedData(data, for: Constants.Cache.lensDataKey)
        
        return data
    }
    
    func fetchCameraData() async throws -> APICameraResponse {
        // Try cache first
        if let cachedData = await cacheService.getCachedData(
            for: Constants.Cache.cameraDataKey,
            type: APICameraResponse.self
        ) {
            return cachedData
        }
        
        // Fetch from local/network
        let data = try await networkService.fetchCameraData()
        
        // Cache the result
        await cacheService.setCachedData(data, for: Constants.Cache.cameraDataKey)
        
        return data
    }
}