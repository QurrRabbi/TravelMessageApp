import Foundation

protocol APIServiceProtocol {
    func get<T: Decodable>(endpoint: String) async throws -> T
    func post<Body: Encodable, Response: Decodable>(endpoint: String, body: Body) async throws -> Response
    func post<Body: Encodable>(endpoint: String, body: Body) async throws
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

    func post<Body: Encodable, Response: Decodable>(endpoint: String, body: Body) async throws -> Response {
        let request = try buildPostRequest(endpoint: endpoint, body: body)
        let (data, _) = try await session.data(for: request)
        return try JSONDecoder().decode(Response.self, from: data)
    }

    func post<Body: Encodable>(endpoint: String, body: Body) async throws {
        let request = try buildPostRequest(endpoint: endpoint, body: body)
        _ = try await session.data(for: request)
    }

    func delete(endpoint: String) async throws {
        var request = URLRequest(url: baseURL.appendingPathComponent(endpoint))
        request.httpMethod = "DELETE"
        _ = try await session.data(for: request)
    }

    private func buildPostRequest<Body: Encodable>(endpoint: String, body: Body) throws -> URLRequest {
        var request = URLRequest(url: baseURL.appendingPathComponent(endpoint))
        request.httpMethod = "POST"
        request.httpBody = try JSONEncoder().encode(body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
}
