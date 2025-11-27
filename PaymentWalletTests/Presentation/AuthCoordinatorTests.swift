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

    // MARK: - Test Doubles

    private final class SpyNavigationController: UINavigationController {
        
        private(set) var setViewControllersCalls: [[UIViewController]] = []

        override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
            setViewControllersCalls.append(viewControllers)
            super.setViewControllers(viewControllers, animated: animated)
        }
        
    }

    private struct SpyAuthRepository: AuthRepository {

        enum Result {
            case success(User)
            case failure(Error)
        }

        var result: Result

        func login(email: String, password: String) throws -> User {
            switch result {
            case .success(let user):
                return user
            case .failure(let error):
                throw error
            }
        }
        
    }

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

    private struct DummyWalletRepository: WalletRepository {
        func getBalance() -> Decimal { 0.0 }
        func getContacts() -> [PaymentWallet.Contact] { [] }
        func transfer(to contact: PaymentWallet.Contact, amount: Decimal) throws {
            // No-op for tests: we don't mutate any state or throw.
            // This dummy repository is only used where transfer side-effects are irrelevant.
        }
    }

    private final class DummyAuthorizationService: AuthorizationService {
        func authorize(amount: Decimal) async -> PaymentWallet.AuthorizationResult {
            fatalError("DummyAuthorizationService.authorize(amount:) should not be called in these tests.")
        }
    }

    private final class DummyNotificationScheduler: LocalNotificationScheduler {
        func scheduleSuccessNotification(for amount: Decimal) {
            // Intentionally not implemented
        }
        func scheduleAuthorizationReminder() {
            // Intentionally not implemented
        }
    }

    @MainActor
    private final class TestDependencies: AppDependencies {

        // Repositories
        let authRepository: AuthRepository
        let walletRepository: WalletRepository

        // Storage
        let authTokenStore: AuthTokenStore

        // Services
        let authorizationService: AuthorizationService
        let notificationScheduler: LocalNotificationScheduler

        init(
            authRepository: AuthRepository,
            authTokenStore: AuthTokenStore
        ) {
            self.authRepository = authRepository
            self.authTokenStore = authTokenStore
            self.walletRepository = DummyWalletRepository()
            self.authorizationService = DummyAuthorizationService()
            self.notificationScheduler = DummyNotificationScheduler()
        }
    }

    // MARK: - Helpers

    private func makeSUT(authResult: SpyAuthRepository.Result? = nil) -> (
        sut: AuthCoordinator,
        nav: SpyNavigationController,
        authRepo: SpyAuthRepository,
        tokenStore: SpyAuthTokenStore
    ) {

        // Default auth result evaluated inside MainActor context
        let effectiveResult: SpyAuthRepository.Result = authResult ?? .success(
            User(name: "Wolfgang Amadeus Mozart", email: "wolfgang@mozart.com")
        )

        let navigationController = SpyNavigationController()
        let authRepo = SpyAuthRepository(result: effectiveResult)
        let tokenStore = SpyAuthTokenStore()
        let dependencies = TestDependencies(authRepository: authRepo, authTokenStore: tokenStore)
        let sut = AuthCoordinator(navigationController: navigationController, dependencies: dependencies)
        return (sut, navigationController, authRepo, tokenStore)
    }

    // MARK: - Tests

    func test_performLogin_onSuccess_callsRepositoryAndSavesToken() async throws {
        // GIVEN
        let (sut, _, _, tokenStore) = makeSUT(
            authResult: .success(
                User(
                    name: "Wolfgang Amadeus Mozart",
                    email: "wolfgang@mozart.com"
                )
            )
        )

        let email = "wolfgang@mozart.com"
        let password = "clarinet_concerto"

        // WHEN
        try await sut.performLogin(email: email, password: password)

        // THEN
        XCTAssertEqual(
            tokenStore.savedTokens.count,
            1,
            "Expected exactly one saved token after successful login."
        )
        XCTAssertNotNil(
            tokenStore.get(),
            "Expected get() to return the last saved token."
        )
    }

    func test_performLogin_onAuthError_invalidCredentials_doesNotSaveTokenAndThrowsAuthError() async {
        // GIVEN
        let authError = AuthError.invalidCredentials

        let (sut, _, _, tokenStore) = makeSUT(
            authResult: .failure(authError)
        )

        let email = "wolfgang@mozart.com"
        let password = "wrong_password"

        // WHEN
        do {
            try await sut.performLogin(email: email, password: password)
            XCTFail("Expected performLogin to throw, but it succeeded.")
        } catch let error as AuthError {
            // THEN
            XCTAssertEqual(
                error,
                authError,
                "Expected AuthError.invalidCredentials to be propagated."
            )
            XCTAssertEqual(
                tokenStore.savedTokens.count,
                0,
                "Token store should not save any token when login fails."
            )
        } catch {
            XCTFail("Expected AuthError, got \(error) instead.")
        }
    }

    func test_performLogin_onUnknownError_throwsUnknownAndDoesNotSaveToken() async {
        // GIVEN
        struct SomeRandomError: Error {}

        let (sut, _, _, tokenStore) = makeSUT(
            authResult: .failure(SomeRandomError())
        )

        let email = "wolfgang@mozart.com"
        let password = "whatever"

        // WHEN
        do {
            try await sut.performLogin(email: email, password: password)
            XCTFail("Expected performLogin to throw, but it succeeded.")
        } catch let error as AuthError {
            // THEN
            XCTAssertEqual(
                error,
                .unknown,
                "Expected unknown errors to be mapped to AuthError.unknown."
            )
            XCTAssertEqual(
                tokenStore.savedTokens.count,
                0,
                "Token store should not save any token when an unknown error occurs."
            )
        } catch {
            XCTFail("Expected AuthError.unknown, got \(error) instead.")
        }
    }
    
}
