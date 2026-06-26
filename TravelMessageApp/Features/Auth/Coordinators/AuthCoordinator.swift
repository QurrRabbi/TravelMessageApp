import UIKit
import SwiftUI

@MainActor
final class AuthCoordinator {
    private let window: UIWindow
    private let authService: AuthServiceProtocol

    init(window: UIWindow, authService: AuthServiceProtocol) {
        self.window = window
        self.authService = authService
    }

    func start() async {
        let viewModel = AuthViewModel(authService: authService)

        // Show login immediately so the window is visible on first frame,
        // then silently attempt session restore in the background.
        showLogin(viewModel: viewModel)

        await viewModel.restoreSession()
        if case .authenticated(let user) = viewModel.state {
            showMainApp(for: user)
        }
    }

    private func showLogin(viewModel: AuthViewModel) {
        let loginView = LoginView(viewModel: viewModel) { [weak self] user in
            self?.showMainApp(for: user)
        }
        let hostingController = UIHostingController(rootView: loginView)
        window.rootViewController = hostingController
        window.makeKeyAndVisible()
    }

    private func showMainApp(for user: User) {
        // TODO: Replace with MainCoordinator once home feature is built
        let placeholder = UIViewController()
        placeholder.view.backgroundColor = .systemBackground
        let label = UILabel()
        label.text = "Welcome, \(user.displayName)!"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        placeholder.view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: placeholder.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: placeholder.view.centerYAnchor)
        ])
        window.rootViewController = placeholder
        window.makeKeyAndVisible()
    }
}
