import Foundation
import CoreLocation
@testable import TravelMessageApp

/// In-memory stand-in for `APIServiceProtocol` that records the calls made to
/// it and returns canned results, so repositories can be tested without network.
final class MockAPIService: APIServiceProtocol {
    var getResult: Any?
    var getError: Error?
    var postResponse: Any?
    var postError: Error?
    var deleteError: Error?

    private(set) var getEndpoints: [String] = []
    private(set) var postEndpoints: [String] = []
    private(set) var postBodies: [Any] = []
    private(set) var deleteEndpoints: [String] = []

    enum MockAPIError: Error { case unexpectedResponseType }

    func get<T: Decodable>(endpoint: String) async throws -> T {
        getEndpoints.append(endpoint)
        if let getError { throw getError }
        guard let value = getResult as? T else { throw MockAPIError.unexpectedResponseType }
        return value
    }

    func post<Body: Encodable, Response: Decodable>(endpoint: String, body: Body) async throws -> Response {
        postEndpoints.append(endpoint)
        postBodies.append(body)
        if let postError { throw postError }
        guard let value = postResponse as? Response else { throw MockAPIError.unexpectedResponseType }
        return value
    }

    func post<Body: Encodable>(endpoint: String, body: Body) async throws {
        postEndpoints.append(endpoint)
        postBodies.append(body)
        if let postError { throw postError }
    }

    func delete(endpoint: String) async throws {
        deleteEndpoints.append(endpoint)
        if let deleteError { throw deleteError }
    }
}

extension Journey {
    static func stub(
        id: String = "journey-1",
        userId: String = "user-123",
        title: String = "Trip to London",
        startDate: Date = Date(timeIntervalSince1970: 0),
        endDate: Date? = nil,
        route: [CLLocationCoordinate2D] = [],
        messages: [Message] = []
    ) -> Journey {
        Journey(
            id: id,
            userId: userId,
            title: title,
            startDate: startDate,
            endDate: endDate,
            route: route,
            messages: messages
        )
    }
}

extension Message {
    static func stub(
        id: String = "message-1",
        journeyId: String = "journey-1",
        authorId: String = "user-123",
        content: String = "Hello from the road",
        photoURLs: [URL] = [],
        coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 51.5007, longitude: -0.1246),
        proximityRadiusMetres: Double = Message.defaultProximityRadiusMetres,
        encryptedShareLink: String? = nil,
        createdAt: Date = Date(timeIntervalSince1970: 0)
    ) -> Message {
        Message(
            id: id,
            journeyId: journeyId,
            authorId: authorId,
            content: content,
            photoURLs: photoURLs,
            coordinate: coordinate,
            proximityRadiusMetres: proximityRadiusMetres,
            encryptedShareLink: encryptedShareLink,
            createdAt: createdAt
        )
    }
}
