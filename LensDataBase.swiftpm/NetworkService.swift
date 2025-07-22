import Foundation
import Combine

class NetworkService {
    static let shared = NetworkService()
    
    private let LENS_DATA_URL = "https://lksrental.site/api.php?action=all"
    
    struct APIResponse: Decodable {
        let success: Bool
        let database: AppData
    }
    
    func fetchLensData() -> AnyPublisher<AppData, Error> {
        guard let url = URL(string: LENS_DATA_URL) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response in
                return data
            }
            .decode(type: APIResponse.self, decoder: JSONDecoder())
            .map { $0.database }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}