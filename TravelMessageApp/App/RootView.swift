import SwiftUI

struct RootView: View {
    @ObservedObject var viewModel: AuthViewModel

    var body: some View {
        Group {
            switch viewModel.state {
            case .authenticated(let user):
                Text("Welcome, \(user.displayName)!")
                    .font(.title)
            default:
                LoginView(viewModel: viewModel, onAuthenticated: { _ in })
            }
        }
        .task {
            await viewModel.restoreSession()
        }
    }
}
