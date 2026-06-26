import XCTest
@testable import TravelMessageApp

final class MessageRepositoryTests: XCTestCase {
    private var mockAPI: MockAPIService!
    private var sut: MessageRepository!

    override func setUp() {
        super.setUp()
        mockAPI = MockAPIService()
        sut = MessageRepository(apiService: mockAPI)
    }

    override func tearDown() {
        sut = nil
        mockAPI = nil
        super.tearDown()
    }

    // MARK: - Fetch

    func test_fetchMessages_requestsJourneyScopedEndpoint_andReturnsResult() async throws {
        mockAPI.getResult = [Message.stub(id: "m1"), Message.stub(id: "m2")]

        let result = try await sut.fetchMessages(for: "journey-1")

        XCTAssertEqual(mockAPI.getEndpoints, ["messages?journeyId=journey-1"])
        XCTAssertEqual(result.map(\.id), ["m1", "m2"])
    }

    func test_fetchMessages_propagatesError() async {
        mockAPI.getError = URLError(.notConnectedToInternet)

        do {
            _ = try await sut.fetchMessages(for: "journey-1")
            XCTFail("Expected fetch to throw")
        } catch {
            XCTAssertTrue(error is URLError)
        }
    }

    // MARK: - Save

    func test_save_postsMessageToMessagesEndpoint() async throws {
        let message = Message.stub(id: "m1")

        try await sut.save(message)

        XCTAssertEqual(mockAPI.postEndpoints, ["messages"])
        XCTAssertEqual((mockAPI.postBodies.first as? Message)?.id, "m1")
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

    func test_delete_callsDeleteEndpointWithMessageId() async throws {
        try await sut.delete("m1")

        XCTAssertEqual(mockAPI.deleteEndpoints, ["messages/m1"])
    }

    func test_delete_propagatesError() async {
        mockAPI.deleteError = URLError(.timedOut)

        do {
            try await sut.delete("m1")
            XCTFail("Expected delete to throw")
        } catch {
            XCTAssertTrue(error is URLError)
        }
    }
}
