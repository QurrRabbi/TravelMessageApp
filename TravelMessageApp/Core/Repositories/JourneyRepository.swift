import Foundation

protocol JourneyRepositoryProtocol {
    func fetchJourneys(for userId: String) async throws -> [Journey]
    func save(_ journey: Journey) async throws
    func delete(_ journeyId: String) async throws
}

final class JourneyRepository: JourneyRepositoryProtocol {
    private let apiService: APIServiceProtocol

    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
    }

    func fetchJourneys(for userId: String) async throws -> [Journey] {
        try await apiService.get(endpoint: "journeys?userId=\(userId)")
    }

    func save(_ journey: Journey) async throws {
        try await apiService.post(endpoint: "journeys", body: journey)
    }

    func delete(_ journeyId: String) async throws {
        try await apiService.delete(endpoint: "journeys/\(journeyId)")
    }
}
