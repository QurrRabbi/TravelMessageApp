import UIKit
import GoogleSignIn

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var authCoordinator: AuthCoordinator?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window

        let apiService = APIService(baseURL: AppConfig.apiBaseURL)
        let keychainService = KeychainService()
        let authService = AuthService(apiService: apiService, keychainService: keychainService)
        let coordinator = AuthCoordinator(window: window, authService: authService)
        self.authCoordinator = coordinator

        Task { await coordinator.start() }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        GIDSignIn.sharedInstance.handle(url)
    }
}

enum AppConfig {
    // Replace with deployed API Gateway URL once backend is provisioned in eu-west-2
    static let apiBaseURL = URL(string: "https://api.travelmessageapp.com")!
}
