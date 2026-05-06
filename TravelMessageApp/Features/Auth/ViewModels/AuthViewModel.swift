import Foundation
import UIKit

@MainActor
final class AuthViewModel: ObservableObject {
    enum State: Equatable {
        case idle
        case loading
        case authenticated(User)
        case error(String)
    }

    @Published private(set) var state: State = .idle

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    func signIn(presenting viewController: UIViewController) async {
        state = .loading
        do {
            let token = try await authService.signIn(presenting: viewController)
            state = .authenticated(token.user)
        } catch AuthError.signInCancelled {
            state = .idle
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func signOut() {
        do {
            try authService.signOut()
            state = .idle
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func restoreSession() async {
        state = .loading
        do {
            if let token = try await authService.restoreSession() {
                state = .authenticated(token.user)
            } else {
                state = .idle
            }
        } catch {
            state = .idle
        }
    }
}
