import XCTest
import Combine
@testable import TravelMessageApp

@MainActor
final class AuthViewModelTests: XCTestCase {
    private var sut: AuthViewModel!
    private var mockAuthService: MockAuthService!

    override func setUp() {
        super.setUp()
        mockAuthService = MockAuthService()
        sut = AuthViewModel(authService: mockAuthService)
    }

    override func tearDown() {
        sut = nil
        mockAuthService = nil
        super.tearDown()
    }

    // MARK: - Initial State

    func test_initialState_isIdle() {
        if case .idle = sut.state { } else {
            XCTFail("Expected idle state, got \(sut.state)")
        }
    }

    // MARK: - Sign In

    func test_signIn_success_transitionsToAuthenticated() async {
        let expectedUser = User.stub()
        mockAuthService.signInResult = .success(.stub(user: expectedUser))

        await sut.signIn(presenting: UIViewController())

        if case .authenticated(let user) = sut.state {
            XCTAssertEqual(user.id, expectedUser.id)
            XCTAssertEqual(user.email, expectedUser.email)
        } else {
            XCTFail("Expected authenticated state, got \(sut.state)")
        }
    }

    func test_signIn_failure_transitionsToError() async {
        mockAuthService.signInResult = .failure(AuthError.missingIdToken)

        await sut.signIn(presenting: UIViewController())

        if case .error(let message) = sut.state {
            XCTAssertFalse(message.isEmpty)
        } else {
            XCTFail("Expected error state, got \(sut.state)")
        }
    }

    func test_signIn_cancelled_transitionsToIdle() async {
        mockAuthService.signInResult = .failure(AuthError.signInCancelled)

        await sut.signIn(presenting: UIViewController())

        if case .idle = sut.state { } else {
            XCTFail("Expected idle state after cancellation, got \(sut.state)")
        }
    }

    func test_signIn_setsLoadingState() async {
        mockAuthService.signInResult = .success(.stub())
        var observedLoading = false
        var cancellable: AnyCancellable?

        cancellable = sut.$state.sink { state in
            if case .loading = state { observedLoading = true }
        }

        await sut.signIn(presenting: UIViewController())
        cancellable?.cancel()

        XCTAssertTrue(observedLoading, "Expected loading state during sign-in")
    }

    // MARK: - Sign Out

    func test_signOut_success_transitionsToIdle() async {
        mockAuthService.signInResult = .success(.stub())
        await sut.signIn(presenting: UIViewController())

        sut.signOut()

        if case .idle = sut.state { } else {
            XCTFail("Expected idle state after sign-out, got \(sut.state)")
        }
        XCTAssertEqual(mockAuthService.signOutCallCount, 1)
    }

    func test_signOut_failure_transitionsToError() {
        mockAuthService.signOutError = AuthError.sessionExpired

        sut.signOut()

        if case .error = sut.state { } else {
            XCTFail("Expected error state, got \(sut.state)")
        }
    }

    // MARK: - Restore Session

    func test_restoreSession_withValidSession_transitionsToAuthenticated() async {
        let expectedUser = User.stub()
        mockAuthService.restoreSessionResult = .success(.stub(user: expectedUser))

        await sut.restoreSession()

        if case .authenticated(let user) = sut.state {
            XCTAssertEqual(user.id, expectedUser.id)
        } else {
            XCTFail("Expected authenticated state, got \(sut.state)")
        }
    }

    func test_restoreSession_withNoSession_remainsIdle() async {
        mockAuthService.restoreSessionResult = .success(nil)

        await sut.restoreSession()

        if case .idle = sut.state { } else {
            XCTFail("Expected idle state when no session, got \(sut.state)")
        }
    }

    func test_restoreSession_callCount() async {
        mockAuthService.restoreSessionResult = .success(nil)

        await sut.restoreSession()

        XCTAssertEqual(mockAuthService.restoreSessionCallCount, 1)
    }
}
