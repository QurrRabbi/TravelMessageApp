import XCTest
import CoreLocation
import CryptoKit
@testable import TravelMessageApp

/// Integration coverage for the core feature: a geo-locked message can only be
/// decrypted when the recipient is physically within the proximity radius of the
/// coordinate where it was originally tagged. Exercises the real
/// `EncryptionService` together with the location/proximity rule.
final class MessageAccessIntegrationTests: XCTestCase {
    /// Deterministic `LocationServiceProtocol` that reports a fixed device
    /// location, so proximity gating can be tested without real GPS.
    private final class StubLocationService: LocationServiceProtocol {
        let location: CLLocation
        init(_ location: CLLocation) { self.location = location }

        func currentLocation() async throws -> CLLocation { location }

        func isWithinProximity(of coordinate: CLLocationCoordinate2D, radiusMetres: Double) async throws -> Bool {
            let target = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            return location.distance(from: target) <= radiusMetres
        }
    }

    private let encryption = EncryptionService()
    // A tagged location in London (the eu-west-2 region).
    private let taggedCoordinate = CLLocationCoordinate2D(latitude: 51.5007, longitude: -0.1246)

    /// Simulates opening a geo-locked message: the content is only decrypted
    /// when the recipient is within the proximity radius of the tagged location.
    private func openMessage(
        encrypted: Data,
        key: SymmetricKey,
        recipientAt location: CLLocation,
        radiusMetres: Double
    ) async throws -> Data? {
        let locationService = StubLocationService(location)
        guard try await locationService.isWithinProximity(of: taggedCoordinate, radiusMetres: radiusMetres) else {
            return nil
        }
        return try encryption.decrypt(encrypted, key: key)
    }

    func test_message_unlocks_whenRecipientWithinProximity() async throws {
        let key = encryption.generateKey()
        let plaintext = Data("Meet me by the river".utf8)
        let encrypted = try encryption.encrypt(plaintext, key: key)

        // ~10 m north of the tagged coordinate — comfortably inside 50 m.
        let nearby = CLLocation(latitude: 51.50079, longitude: -0.1246)

        let opened = try await openMessage(
            encrypted: encrypted,
            key: key,
            recipientAt: nearby,
            radiusMetres: Message.defaultProximityRadiusMetres
        )

        XCTAssertEqual(opened, plaintext)
    }

    func test_message_staysLocked_whenRecipientBeyondProximity() async throws {
        let key = encryption.generateKey()
        let encrypted = try encryption.encrypt(Data("secret".utf8), key: key)

        // ~145 m north of the tagged coordinate — outside the 50 m threshold.
        let faraway = CLLocation(latitude: 51.5020, longitude: -0.1246)

        let opened = try await openMessage(
            encrypted: encrypted,
            key: key,
            recipientAt: faraway,
            radiusMetres: Message.defaultProximityRadiusMetres
        )

        XCTAssertNil(opened, "Message must remain locked beyond the 50 m proximity threshold")
    }

    func test_proximityGate_usesFiftyMetreDefault() {
        XCTAssertEqual(Message.defaultProximityRadiusMetres, 50.0)
    }
}
