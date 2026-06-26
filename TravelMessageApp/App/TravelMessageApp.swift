import Foundation
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

    // True only when this process is the host app for an XCTest bundle. XCTest
    // sets this environment variable for the test host; it is never present in a
    // normal (debug or release) launch, so the real UI always boots outside tests.
    private var isRunningUnitTests: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }

    var body: some Scene {
        WindowGroup {
            if isRunningUnitTests {
                // Avoid booting the full sign-in UI in the unit-test host;
                // the tests exercise the logic layer directly.
                EmptyView()
            } else {
                RootView(viewModel: authViewModel)
            }
        }
    }
}

enum AppConfig {
    static let apiBaseURL = URL(string: "https://api.travelmessageapp.com")!
}
