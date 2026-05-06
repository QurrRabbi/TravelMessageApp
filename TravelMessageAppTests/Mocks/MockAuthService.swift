import UIKit
@testable import TravelMessageApp

final class MockAuthService: AuthServiceProtocol {
    var signInResult: Result<AuthToken, Error> = .failure(AuthError.missingIdToken)
    var signOutError: Error?
    var restoreSessionResult: Result<AuthToken?, Error> = .success(nil)

    private(set) var signInCallCount = 0
    private(set) var signOutCallCount = 0
    private(set) var restoreSessionCallCount = 0

    func signIn(presenting viewController: UIViewController) async throws -> AuthToken {
        signInCallCount += 1
        return try signInResult.get()
    }

    func signOut() throws {
        signOutCallCount += 1
        if let error = signOutError { throw error }
    }

    func restoreSession() async throws -> AuthToken? {
        restoreSessionCallCount += 1
        return try restoreSessionResult.get()
    }
}

extension AuthToken {
    static func stub(
        idToken: String = "id-token",
        accessToken: String = "access-token",
        user: User = .stub()
    ) -> AuthToken {
        AuthToken(idToken: idToken, accessToken: accessToken, user: user)
    }
}

extension User {
    static func stub(
        id: String = "user-123",
        email: String = "test@example.com",
        displayName: String = "Test User",
        profileImageURL: URL? = nil
    ) -> User {
        User(id: id, email: email, displayName: displayName, profileImageURL: profileImageURL)
    }
}
