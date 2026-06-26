import SwiftUI

@main
struct TravelMessageMainApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var authViewModel = AuthViewModel(
        authService: AuthService(
            apiService: APIService(baseURL: AppConfig.apiBaseURL),
            keychainService: KeychainService()
        )
    )

    var body: some Scene {
        WindowGroup {
            RootView(viewModel: authViewModel)
        }
    }
}

enum AppConfig {
    static let apiBaseURL = URL(string: "https://api.travelmessageapp.com")!
}
