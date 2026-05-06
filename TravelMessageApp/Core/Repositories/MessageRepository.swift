import Foundation

protocol MessageRepositoryProtocol {
    func fetchMessages(for journeyId: String) async throws -> [Message]
    func save(_ message: Message) async throws
    func delete(_ messageId: String) async throws
}

final class MessageRepository: MessageRepositoryProtocol {
    private let apiService: APIServiceProtocol

    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
    }

    func fetchMessages(for journeyId: String) async throws -> [Message] {
        try await apiService.get(endpoint: "messages?journeyId=\(journeyId)")
    }

    func save(_ message: Message) async throws {
        try await apiService.post(endpoint: "messages", body: message)
    }

    func delete(_ messageId: String) async throws {
        try await apiService.delete(endpoint: "messages/\(messageId)")
    }
}
