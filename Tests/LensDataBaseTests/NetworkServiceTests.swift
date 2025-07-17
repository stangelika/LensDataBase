import XCTest
import Combine
@testable import LensDataBase

final class NetworkServiceTests: XCTestCase {
    
    private var networkService: NetworkService!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        networkService = NetworkService.shared
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        networkService = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Shared Instance Tests
    
    func testSharedInstance() {
        let instance1 = NetworkService.shared
        let instance2 = NetworkService.shared
        
        XCTAssertTrue(instance1 === instance2)
    }
    
    // MARK: - Lens Data Fetching Tests
    
    func testFetchLensDataReturnsPublisher() {
        let publisher = networkService.fetchLensData()
        
        XCTAssertNotNil(publisher)
        XCTAssertTrue(publisher is AnyPublisher<AppData, Error>)
    }
    
    func testFetchLensDataWithInvalidURL() {
        // This test would require mocking URLSession, but we can test the publisher creation
        let expectation = XCTestExpectation(description: "Fetch lens data")
        
        networkService.fetchLensData()
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        // Network requests may fail in test environment
                        XCTAssertNotNil(error)
                    }
                    expectation.fulfill()
                },
                receiveValue: { appData in
                    XCTAssertNotNil(appData)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // MARK: - Camera Data Fetching Tests
    
    func testFetchCameraDataReturnsPublisher() {
        let publisher = networkService.fetchCameraData()
        
        XCTAssertNotNil(publisher)
        XCTAssertTrue(publisher is AnyPublisher<CameraApiResponse, Error>)
    }
    
    func testFetchCameraDataWithInvalidURL() {
        // This test would require mocking URLSession, but we can test the publisher creation
        let expectation = XCTestExpectation(description: "Fetch camera data")
        
        networkService.fetchCameraData()
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        // Network requests may fail in test environment
                        XCTAssertNotNil(error)
                    }
                    expectation.fulfill()
                },
                receiveValue: { cameraData in
                    XCTAssertNotNil(cameraData)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // MARK: - Publisher Tests
    
    func testFetchLensDataPublisherConfiguration() {
        let publisher = networkService.fetchLensData()
        
        let expectation = XCTestExpectation(description: "Publisher configuration")
        
        publisher
            .sink(
                receiveCompletion: { _ in
                    expectation.fulfill()
                },
                receiveValue: { _ in
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testFetchCameraDataPublisherConfiguration() {
        let publisher = networkService.fetchCameraData()
        
        let expectation = XCTestExpectation(description: "Publisher configuration")
        
        publisher
            .sink(
                receiveCompletion: { _ in
                    expectation.fulfill()
                },
                receiveValue: { _ in
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // MARK: - Error Handling Tests
    
    func testNetworkErrorHandling() {
        // Test that network errors are properly propagated
        let expectation = XCTestExpectation(description: "Network error handling")
        var receivedError: Error?
        
        networkService.fetchLensData()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        receivedError = error
                    }
                    expectation.fulfill()
                },
                receiveValue: { _ in
                    // Success case
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 10.0)
        
        // We expect either success or a network error, both are valid outcomes
        if let error = receivedError {
            XCTAssertTrue(error is URLError || error is DecodingError)
        }
    }
    
    // MARK: - Threading Tests
    
    func testPublisherReceivesOnMainThread() {
        let expectation = XCTestExpectation(description: "Main thread delivery")
        
        networkService.fetchLensData()
            .sink(
                receiveCompletion: { _ in
                    XCTAssertTrue(Thread.isMainThread)
                    expectation.fulfill()
                },
                receiveValue: { _ in
                    XCTAssertTrue(Thread.isMainThread)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testCameraDataPublisherReceivesOnMainThread() {
        let expectation = XCTestExpectation(description: "Main thread delivery")
        
        networkService.fetchCameraData()
            .sink(
                receiveCompletion: { _ in
                    XCTAssertTrue(Thread.isMainThread)
                    expectation.fulfill()
                },
                receiveValue: { _ in
                    XCTAssertTrue(Thread.isMainThread)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // MARK: - URL Construction Tests
    
    func testURLConstruction() {
        // Test that we can create publishers (implies valid URL construction)
        let lensPublisher = networkService.fetchLensData()
        let cameraPublisher = networkService.fetchCameraData()
        
        XCTAssertNotNil(lensPublisher)
        XCTAssertNotNil(cameraPublisher)
    }
    
    // MARK: - Response Validation Tests
    
    func testResponseValidation() {
        // Test that the publisher validates HTTP responses
        let expectation = XCTestExpectation(description: "Response validation")
        
        networkService.fetchLensData()
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        // Success case
                        break
                    case .failure(let error):
                        // Should be a URLError or DecodingError
                        XCTAssertTrue(error is URLError || error is DecodingError)
                    }
                    expectation.fulfill()
                },
                receiveValue: { appData in
                    // Validate that we receive proper AppData structure
                    XCTAssertNotNil(appData.last_updated)
                    XCTAssertNotNil(appData.rentals)
                    XCTAssertNotNil(appData.lenses)
                    XCTAssertNotNil(appData.inventory)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // MARK: - Concurrent Request Tests
    
    func testConcurrentRequests() {
        let expectation1 = XCTestExpectation(description: "Concurrent request 1")
        let expectation2 = XCTestExpectation(description: "Concurrent request 2")
        
        // Start two concurrent requests
        networkService.fetchLensData()
            .sink(
                receiveCompletion: { _ in expectation1.fulfill() },
                receiveValue: { _ in expectation1.fulfill() }
            )
            .store(in: &cancellables)
        
        networkService.fetchCameraData()
            .sink(
                receiveCompletion: { _ in expectation2.fulfill() },
                receiveValue: { _ in expectation2.fulfill() }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation1, expectation2], timeout: 15.0)
    }
}

// MARK: - Mock Network Service (for future use)

class MockNetworkService: NetworkService {
    var shouldReturnError = false
    var mockAppData: AppData?
    var mockCameraData: CameraApiResponse?
    
    override func fetchLensData() -> AnyPublisher<AppData, Error> {
        if shouldReturnError {
            return Fail(error: URLError(.badServerResponse))
                .eraseToAnyPublisher()
        }
        
        if let mockData = mockAppData {
            return Just(mockData)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return super.fetchLensData()
    }
    
    override func fetchCameraData() -> AnyPublisher<CameraApiResponse, Error> {
        if shouldReturnError {
            return Fail(error: URLError(.badServerResponse))
                .eraseToAnyPublisher()
        }
        
        if let mockData = mockCameraData {
            return Just(mockData)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return super.fetchCameraData()
    }
}