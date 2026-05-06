import Foundation

protocol APIServiceProtocol {
    func get<T: Decodable>(endpoint: String) async throws -> T
    func post<T: Encodable>(endpoint: String, body: T) async throws
    func delete(endpoint: String) async throws
}

final class APIService: APIServiceProtocol {
    private let baseURL: URL
    private let session: URLSession

    init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    func get<T: Decodable>(endpoint: String) async throws -> T {
        let request = URLRequest(url: baseURL.appendingPathComponent(endpoint))
        let (data, _) = try await session.data(for: request)
        return try JSONDecoder().decode(T.self, from: data)
    }

    func post<T: Encodable>(endpoint: String, body: T) async throws {
        var request = URLRequest(url: baseURL.appendingPathComponent(endpoint))
        request.httpMethod = "POST"
        request.httpBody = try JSONEncoder().encode(body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        _ = try await session.data(for: request)
    }

    func delete(endpoint: String) async throws {
        var request = URLRequest(url: baseURL.appendingPathComponent(endpoint))
        request.httpMethod = "DELETE"
        _ = try await session.data(for: request)
    }
}
