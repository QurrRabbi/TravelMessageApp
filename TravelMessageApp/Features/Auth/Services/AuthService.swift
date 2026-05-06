import Foundation
import GoogleSignIn

protocol AuthServiceProtocol {
    func signIn(presenting viewController: UIViewController) async throws -> AuthToken
    func signOut() throws
    func restoreSession() async throws -> AuthToken?
}

struct AuthToken {
    let idToken: String
    let accessToken: String
    let user: User
}

final class AuthService: AuthServiceProtocol {
    private let apiService: APIServiceProtocol
    private let keychainService: KeychainServiceProtocol

    init(apiService: APIServiceProtocol, keychainService: KeychainServiceProtocol) {
        self.apiService = apiService
        self.keychainService = keychainService
    }

    func signIn(presenting viewController: UIViewController) async throws -> AuthToken {
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: viewController)
        guard let idToken = result.user.idToken?.tokenString else {
            throw AuthError.missingIdToken
        }

        let sessionToken: SessionTokenResponse = try await apiService.post(
            endpoint: "auth/signin",
            body: GoogleSignInRequest(idToken: idToken)
        )

        try keychainService.save(sessionToken.token, forKey: .sessionToken)

        return AuthToken(
            idToken: idToken,
            accessToken: result.user.accessToken.tokenString,
            user: User(
                id: result.user.userID ?? "",
                email: result.user.profile?.email ?? "",
                displayName: result.user.profile?.name ?? "",
                profileImageURL: result.user.profile?.imageURL(withDimension: 200)
            )
        )
    }

    func signOut() throws {
        GIDSignIn.sharedInstance.signOut()
        try keychainService.delete(forKey: .sessionToken)
    }

    func restoreSession() async throws -> AuthToken? {
        guard keychainService.load(forKey: .sessionToken) != nil else { return nil }
        do {
            try await GIDSignIn.sharedInstance.restorePreviousSignIn()
            guard let user = GIDSignIn.sharedInstance.currentUser,
                  let idToken = user.idToken?.tokenString else { return nil }
            return AuthToken(
                idToken: idToken,
                accessToken: user.accessToken.tokenString,
                user: User(
                    id: user.userID ?? "",
                    email: user.profile?.email ?? "",
                    displayName: user.profile?.name ?? "",
                    profileImageURL: user.profile?.imageURL(withDimension: 200)
                )
            )
        } catch {
            return nil
        }
    }
}

enum AuthError: LocalizedError {
    case missingIdToken
    case sessionExpired
    case signInCancelled

    var errorDescription: String? {
        switch self {
        case .missingIdToken: return "Unable to retrieve Google ID token."
        case .sessionExpired: return "Your session has expired. Please sign in again."
        case .signInCancelled: return "Sign-in was cancelled."
        }
    }
}

private struct GoogleSignInRequest: Encodable {
    let idToken: String
}

private struct SessionTokenResponse: Decodable {
    let token: String
}
