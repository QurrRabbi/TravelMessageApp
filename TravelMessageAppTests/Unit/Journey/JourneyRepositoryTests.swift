import XCTest
@testable import TravelMessageApp

final class JourneyRepositoryTests: XCTestCase {
    private var mockAPI: MockAPIService!
    private var sut: JourneyRepository!

    override func setUp() {
        super.setUp()
        mockAPI = MockAPIService()
        sut = JourneyRepository(apiService: mockAPI)
    }

    override func tearDown() {
        sut = nil
        mockAPI = nil
        super.tearDown()
    }

    // MARK: - Fetch

    func test_fetchJourneys_requestsUserScopedEndpoint_andReturnsResult() async throws {
        mockAPI.getResult = [Journey.stub(id: "j1"), Journey.stub(id: "j2")]

        let result = try await sut.fetchJourneys(for: "user-123")

        XCTAssertEqual(mockAPI.getEndpoints, ["journeys?userId=user-123"])
        XCTAssertEqual(result.map(\.id), ["j1", "j2"])
    }

    func test_fetchJourneys_propagatesError() async {
        mockAPI.getError = URLError(.notConnectedToInternet)

        do {
            _ = try await sut.fetchJourneys(for: "user-123")
            XCTFail("Expected fetch to throw")
        } catch {
            XCTAssertTrue(error is URLError)
        }
    }

    // MARK: - Save

    func test_save_postsJourneyToJourneysEndpoint() async throws {
        let journey = Journey.stub(id: "j1")

        try await sut.save(journey)

        XCTAssertEqual(mockAPI.postEndpoints, ["journeys"])
        XCTAssertEqual((mockAPI.postBodies.first as? Journey)?.id, "j1")
    }

    func test_save_propagatesError() async {
        mockAPI.postError = URLError(.badServerResponse)

        do {
            try await sut.save(.stub())
            XCTFail("Expected save to throw")
        } catch {
            XCTAssertTrue(error is URLError)
        }
    }

    // MARK: - Delete

    func test_delete_callsDeleteEndpointWithJourneyId() async throws {
        try await sut.delete("j1")

        XCTAssertEqual(mockAPI.deleteEndpoints, ["journeys/j1"])
    }

    func test_delete_propagatesError() async {
        mockAPI.deleteError = URLError(.timedOut)

        do {
            try await sut.delete("j1")
            XCTFail("Expected delete to throw")
        } catch {
            XCTAssertTrue(error is URLError)
        }
    }
}
