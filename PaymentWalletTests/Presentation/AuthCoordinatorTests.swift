//
//  AuthCoordinatorTests.swift
//  PaymentWalletTests
//
//  Created by Marcello Chuahy on 26/11/25.
//

import XCTest
import UIKit
import AuthFeature

@testable import PaymentWallet

@MainActor
final class AuthCoordinatorTests: XCTestCase {
    
    // MARK: - Test Factory
    
    /// Builds a fully isolated AuthCoordinator instance with all test doubles injected.
    ///
    /// - Parameter authResult: Optional simulated result for AuthRepository.login.
    /// - Returns: Tuple containing the SUT, navigation spy, token store spy and analytics spy.
    private func makeSUT(
        authResult: SpyAuthRepository.Result? = nil
    ) -> (
        sut: TestableAuthCoordinator,
        nav: SpyNavigationController,
        tokenStore: SpyAuthTokenStore,
        analytics: SpyAnalyticsService
    ) {
        
        // Default simulated login result for performLogin tests
        let effectiveResult = authResult ?? .success(
            User(name: "Wolfgang Amadeus Mozart", email: "wolfgang@mozart.com")
        )
        
        let navigationController = SpyNavigationController()
        let authRepo = SpyAuthRepository(result: effectiveResult)
        let tokenStore = SpyAuthTokenStore()
        let analyticsSpy = SpyAnalyticsService()
        
        // All other dependencies are safe dummies (no fatalError, no real side effects)
        let dependencies = MockDependencies(
            authRepository: authRepo,
            authTokenStore: tokenStore,
            walletRepository: DummyWalletRepository(),
            authorizationService: DummyAuthorizationService(),
            notificationScheduler: DummyNotificationScheduler(),
            analytics: analyticsSpy
        )
        
        let sut = TestableAuthCoordinator(
            navigationController: navigationController,
            dependencies: dependencies
        )
        
        return (sut, navigationController, tokenStore, analyticsSpy)
    }

    // MARK: - Tests (performLogin)
    
    func test_performLogin_onSuccess_callsRepositoryAndSavesToken() async throws {
        // GIVEN
        let authResult: SpyAuthRepository.Result = .success(User(name: "Wolfgang Amadeus Mozart", email: "wolfgang@mozart.com"))
        let (sut, _, tokenStore, _) = makeSUT(authResult: authResult)
        
        let email = "wolfgang@mozart.com"
        let password = "clarinet_concerto"
        
        // WHEN
        try await sut.performLogin(email: email, password: password)
        
        // THEN
        XCTAssertEqual(tokenStore.savedTokens.count, 1, "Coordinator should persist exactly one token after a successful login.")
        XCTAssertNotNil(tokenStore.get(), "TokenStore.get() should return the persisted token.")
        XCTAssertTrue((tokenStore.get() ?? "").isNotEmpty, "Persisted token must not be empty.")
    }
    
    func test_performLogin_onAuthError_invalidCredentials_doesNotSaveTokenAndThrowsAuthError() async {
        // GIVEN
        let authResult: SpyAuthRepository.Result = .failure(AuthError.invalidCredentials)
        let (sut, _, tokenStore, _) = makeSUT(authResult: authResult)
        
        let email = "wolfgang@mozart.com"
        let password = "wrong_password"
        
        // WHEN
        do {
            try await sut.performLogin(email: email, password: password)
            XCTFail("Expected performLogin to throw, but it succeeded.")
        }
        catch let error as AuthError {
            
            // THEN
            XCTAssertEqual(error, AuthError.invalidCredentials, "Expected invalidCredentials to be propagated as-is.")
            XCTAssertEqual(tokenStore.savedTokens.count, 0, "No token must be saved on failed login.")
        }
        catch {
            XCTFail("Expected AuthError.invalidCredentials, got \(error)")
        }
    }
    
    func test_performLogin_onUnknownError_throwsUnknownAndDoesNotSaveToken() async {
        // GIVEN
        struct RandomFailure: Error {}
        let authResult: SpyAuthRepository.Result = .failure(RandomFailure())
        let (sut, _, tokenStore, _) = makeSUT(authResult: authResult)
        
        // WHEN
        do {
            try await sut.performLogin(email: "wolfgang@mozart.com", password: "whatever")
            XCTFail("Expected performLogin to throw, but it succeeded.")
        }
        catch let error as AuthError {
            // THEN
            XCTAssertEqual(error, .unknown, "Coordinator must map unexpected errors to AuthError.unknown.")
            XCTAssertEqual(tokenStore.savedTokens.count, 0, "No token must be written when unknown errors occur.")
        }
        catch {
            XCTFail("Expected AuthError.unknown, got \(error)")
        }
    }
    
    // ✅ Requirement 1.2.
    // MARK: - Tests (start / auto-login)
    
    func test_start_whenNoToken_showsLoginScreen() {
        // GIVEN
        let (sut, nav, tokenStore, _) = makeSUT()
        XCTAssertNil(tokenStore.get(), "Precondition: Store must begin without tokens.")
        
        // WHEN
        sut.start()
        
        // THEN
        XCTAssertEqual(nav.setViewControllersCalls.count, 1, "Coordinator should display the login screen when no token exists.")
        
        let root = nav.setViewControllersCalls.first?.first
        XCTAssertEqual(root?.title, "Login", "Coordinator must push a Login screen when no token is available.")
    }
    
    func test_start_whenTokenExists_skipsLoginAndDoesNotShowLogin() {
        // GIVEN
        let (sut, nav, tokenStore, _) = makeSUT()
        tokenStore.save(token: "existing-token")
        
        // WHEN
        sut.start()
        
        // THEN
        XCTAssertEqual(nav.setViewControllersCalls.count, 1, "Coordinator should update navigation exactly once during auto-login.")
        
        let root = nav.setViewControllersCalls.first?.first
        XCTAssertNotEqual(root?.title, "Login", "If a valid token exists, Login must NOT be shown.")
    }
    
    /// Verifies that when a persisted token exists, AuthCoordinator.start()
    /// sends an 'auto_login_used' analytics event including the same token.
    func test_start_whenTokenExists_logsAutoLoginUsedEventWithToken() {
        // GIVEN
        let (sut, _, tokenStore, analytics) = makeSUT()
        let existingToken = "existing-token-123"
        tokenStore.save(token: existingToken)
        
        // WHEN
        sut.start()
        
        // THEN
        XCTAssertEqual(
            analytics.events.count,
            1,
            "AuthCoordinator should send exactly one analytics event for auto-login."
        )
        
        let event = analytics.events.first
        XCTAssertEqual(
            event?.name,
            "auto_login_used",
            "Expected the auto-login analytics event name to be 'auto_login_used'."
        )
        
        XCTAssertEqual(
            event?.parameters["token"],
            existingToken,
            "Analytics should receive the same token that was read from AuthTokenStore."
        )
        
        XCTAssertNotNil(
            event?.parameters["timestamp"],
            "Analytics auto-login event should include a timestamp parameter."
        )
    }
   
}

// MARK: - TestableAuthCoordinator

/// Test-specific subclass that prevents SwiftUI/UIHostingController instantiation.
/// It replaces the Login screen with a lightweight fake UIViewController.
@MainActor
private final class TestableAuthCoordinator: AuthCoordinator {
    
    /// Lightweight fake Login view controller used in tests.
    override func makeLoginViewController() -> UIViewController {
        let vc = UIViewController()
        vc.title = "Login"
        return vc
    }
    
    /// Overrides the real Home flow to avoid instantiating SwiftUI / HomeCoordinator.
    /// In tests, we only care that Login is *not* shown when a token exists.
    override func handleLoginSuccess() {
        let homeVC = UIViewController()
        homeVC.title = "Home (Test)"
        navigationController.setViewControllers([homeVC], animated: false)
    }
}

// MARK: - MockDependencies

@MainActor
private final class MockDependencies: AppDependencies {
    
    let authRepository: AuthRepository
    let walletRepository: WalletRepository
    let authTokenStore: AuthTokenStore
    let authorizationService: AuthorizationService
    let notificationScheduler: LocalNotificationScheduler
    let analytics: AnalyticsService
    
    init(
        authRepository: AuthRepository,
        authTokenStore: AuthTokenStore,
        walletRepository: WalletRepository = DummyWalletRepository(),
        authorizationService: AuthorizationService = DummyAuthorizationService(),
        notificationScheduler: LocalNotificationScheduler = DummyNotificationScheduler(),
        analytics: AnalyticsService = SpyAnalyticsService()
    ) {
        self.authRepository = authRepository
        self.authTokenStore = authTokenStore
        self.walletRepository = walletRepository
        self.authorizationService = authorizationService
        self.notificationScheduler = notificationScheduler
        self.analytics = analytics
    }
}

// MARK: - Spies

/// Captures every call to setViewControllers so tests can assert navigation behavior.
private final class SpyNavigationController: UINavigationController {
    
    private(set) var setViewControllersCalls: [[UIViewController]] = []
    
    override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        setViewControllersCalls.append(viewControllers)
        super.setViewControllers(viewControllers, animated: animated)
    }
}

/// Fake AuthRepository that simulates success or failure depending on configuration.
private struct SpyAuthRepository: AuthRepository {
    
    enum Result {
        case success(User)
        case failure(Error)
    }
    
    var result: Result
    
    func login(email: String, password: String) throws -> (user: User, token: String) {
        switch result {
        case .success(let user):
            return (user: user, token: "dummy-token")
        case .failure(let error):
            throw error
        }
    }
}

/// Captures saved tokens and allows tests to inspect them.
private final class SpyAuthTokenStore: AuthTokenStore {
    
    private(set) var savedTokens: [String] = []
    private(set) var clearCalls = 0
    
    func save(token: String) {
        savedTokens.append(token)
    }
    
    func get() -> String? {
        savedTokens.last
    }
    
    func clear() {
        clearCalls += 1
        savedTokens.removeAll()
    }
}

/// Spy implementation of AnalyticsService used to assert that AuthCoordinator sends the expected analytics events.
private final class SpyAnalyticsService: AnalyticsService {
    
    struct LoggedEvent: Equatable {
        let name: String
        let parameters: [String: String]
    }
    
    private(set) var events: [LoggedEvent] = []
    
    func logEvent(_ name: String, parameters: [String : String]) {
        events.append(LoggedEvent(name: name, parameters: parameters))
    }
}

// MARK: - Dummies

private struct DummyWalletRepository: WalletRepository {
    func getBalance() -> Decimal { 0.0 }
    func getContacts() -> [PaymentWallet.Contact] { [] }
    func transfer(to contact: PaymentWallet.Contact, amount: Decimal) throws {}
}

private final class DummyAuthorizationService: AuthorizationService {
    func authorize(amount: Decimal) async -> PaymentWallet.AuthorizationResult {
        fatalError("DummyAuthorizationService should not be invoked in these tests.")
    }
}

private final class DummyNotificationScheduler: LocalNotificationScheduler {
    func scheduleSuccessNotification(for amount: Decimal) {}
    func scheduleAuthorizationReminder() {}
}

private final class DummyAnalyticsService: AnalyticsService {
    func logEvent(_ name: String, parameters: [String: String]) {}
}
