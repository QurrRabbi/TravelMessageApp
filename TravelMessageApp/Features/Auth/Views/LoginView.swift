import SwiftUI
import GoogleSignInSwift

struct LoginView: View {
    @StateObject private var viewModel: AuthViewModel
    private let onAuthenticated: (User) -> Void

    init(viewModel: AuthViewModel, onAuthenticated: @escaping (User) -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onAuthenticated = onAuthenticated
    }

    var body: some View {
        ZStack {
            backgroundGradient
            VStack(spacing: 32) {
                Spacer()
                appLogo
                appTitle
                Spacer()
                signInSection
                Spacer()
            }
            .padding(.horizontal, 32)

            if case .loading = viewModel.state {
                loadingOverlay
            }
        }
        .alert("Sign-in Error", isPresented: .constant(errorMessage != nil), actions: {
            Button("OK") {}
        }, message: {
            Text(errorMessage ?? "")
        })
        .onChange(of: viewModel.state) { _, newState in
            if case .authenticated(let user) = newState {
                onAuthenticated(user)
            }
        }
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [Color(.systemBlue).opacity(0.8), Color(.systemTeal)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var appLogo: some View {
        Image(systemName: "map.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 80, height: 80)
            .foregroundStyle(.white)
            .shadow(radius: 8)
    }

    private var appTitle: some View {
        VStack(spacing: 8) {
            Text("TravelMessage")
                .font(.largeTitle.bold())
                .foregroundStyle(.white)
            Text("Leave messages for friends around the world")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.85))
                .multilineTextAlignment(.center)
        }
    }

    private var signInSection: some View {
        VStack(spacing: 16) {
            GoogleSignInButton(scheme: .light, style: .wide, state: .normal) {
                Task { await signIn() }
            }
            .frame(height: 50)
            .cornerRadius(8)
            .shadow(radius: 4)

            if case .error = viewModel.state {
                Text(errorMessage ?? "")
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var loadingOverlay: some View {
        Color.black.opacity(0.3)
            .ignoresSafeArea()
            .overlay {
                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.5)
            }
    }

    private var errorMessage: String? {
        if case .error(let message) = viewModel.state { return message }
        return nil
    }

    @MainActor
    private func signIn() async {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else { return }
        await viewModel.signIn(presenting: rootVC)
    }
}


