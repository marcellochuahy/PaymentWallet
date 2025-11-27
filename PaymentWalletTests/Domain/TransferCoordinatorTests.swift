//
//  TransferCoordinatorTests.swift
//  PaymentWalletTests
//
//  Created by Marcello Chuahy on 27/11/25.
//

import XCTest
@testable import PaymentWallet
import TransferFeature

@MainActor
final class TransferCoordinatorTests: XCTestCase {

    // MARK: - Helpers

    private func makeSUT(
        isAuthorized: Bool = true,
        authReason: String? = nil,
        repoErrorToThrow: Error? = nil
    ) -> (
        sut: TransferCoordinator,
        walletRepo: WalletRepositorySpy,
        authService: AuthorizationServiceStub,
        notificationSpy: NotificationSchedulerSpy,
        beneficiary: TransferFeatureEntryPoint.Beneficiary,
        amount: Decimal
    ) {

        // Domain contact
        let contact = Contact(
            id: UUID(),
            name: "Ludwig van Beethoven",
            email: "ludwig@example.com",
            accountDescription: "Conta corrente"
        )

        let walletRepo = WalletRepositorySpy(
            contacts: [contact],
            balance: 1_200.50
        )
        walletRepo.errorToThrow = repoErrorToThrow

        let authResult = AuthorizationResult(
            isAuthorized: isAuthorized,
            reason: authReason
        )
        let authService = AuthorizationServiceStub(result: authResult)

        let notificationSpy = NotificationSchedulerSpy()
        let dummyAuthTokenStore = DummyAuthTokenStore()
        let dummyAuthRepo = DummyAuthRepository()

        let dependencies = TestDependenciesContainer(
            authRepository: dummyAuthRepo,
            walletRepository: walletRepo,
            authTokenStore: dummyAuthTokenStore,
            authorizationService: authService,
            notificationScheduler: notificationSpy
        )

        let nav = UINavigationController()

        let sut = TransferCoordinator(
            navigationController: nav,
            dependencies: dependencies
        )

        let beneficiary = TransferFeatureEntryPoint.Beneficiary(
            id: contact.id,
            name: contact.name,
            accountDescription: contact.accountDescription
        )

        return (sut, walletRepo, authService, notificationSpy, beneficiary, 100)
    }

    // MARK: - Tests

    func test_performTransfer_whenNotAuthorized_throwsNotAuthorizedAndDoesNotCallRepositoryOrNotification() async throws {
        // GIVEN
        let reason = "operation not allowed"
        let (sut, walletRepo, _, notificationSpy, beneficiary, amount) = makeSUT(
            isAuthorized: false,
            authReason: reason
        )

        // WHEN / THEN
        do {
            try await sut.performTransfer(to: beneficiary, amount: amount)
            XCTFail("Expected performTransfer to throw when authorization fails.")
        } catch let error as TransferError {
            XCTAssertEqual(
                error,
                .notAuthorized(reason: reason),
                "Should map AuthorizationService denial into TransferError.notAuthorized."
            )
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }

        XCTAssertTrue(walletRepo.receivedTransfers.isEmpty, "Repository.transfer should not be called when not authorized.")
        XCTAssertTrue(notificationSpy.successAmounts.isEmpty, "No success notification should be scheduled when not authorized.")
    }

    func test_performTransfer_whenAuthorized_callsRepositoryAndSchedulesNotification() async throws {
        // GIVEN
        let (sut, walletRepo, _, notificationSpy, beneficiary, amount) = makeSUT(
            isAuthorized: true
        )

        let initialBalance = walletRepo.balance

        // WHEN
        try await sut.performTransfer(to: beneficiary, amount: amount)

        // THEN
        XCTAssertEqual(
            walletRepo.receivedTransfers.count,
            1,
            "Repository.transfer should be called exactly once."
        )

        let recorded = try XCTUnwrap(walletRepo.receivedTransfers.first)
        XCTAssertEqual(recorded.contact.id, beneficiary.id)
        XCTAssertEqual(recorded.amount, amount)

        XCTAssertEqual(
            walletRepo.balance,
            initialBalance - amount,
            "Balance should be debited by the transferred amount."
        )

        XCTAssertEqual(
            notificationSpy.successAmounts,
            [amount],
            "A success notification should be scheduled with the same amount."
        )
    }

    func test_performTransfer_whenContactNotFound_throwsUnknownError() async throws {
        // GIVEN – repositório sem o contato correspondente
        let emptyRepo = WalletRepositorySpy(
            contacts: [],
            balance: 500
        )
        let authResult = AuthorizationResult(isAuthorized: true, reason: nil)
        let authService = AuthorizationServiceStub(result: authResult)
        let notificationSpy = NotificationSchedulerSpy()
        let dummyAuthTokenStore = DummyAuthTokenStore()
        let dummyAuthRepo = DummyAuthRepository()

        let dependencies = TestDependenciesContainer(
            authRepository: dummyAuthRepo,
            walletRepository: emptyRepo,
            authTokenStore: dummyAuthTokenStore,
            authorizationService: authService,
            notificationScheduler: notificationSpy
        )

        let navigationController = UINavigationController()
        let sut = TransferCoordinator(
            navigationController: navigationController,
            dependencies: dependencies
        )

        // Beneficiário com ID que não existe no repositório
        let bogusBeneficiary = TransferFeatureEntryPoint.Beneficiary(
            id: UUID(),
            name: "Ghost",
            accountDescription: "N/A"
        )

        // WHEN / THEN
        do {
            try await sut.performTransfer(to: bogusBeneficiary, amount: 50)
            XCTFail("Expected performTransfer to throw when contact cannot be resolved.")
        } catch let error as TransferError {
            XCTAssertEqual(error, .unknown)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }

        XCTAssertTrue(
            emptyRepo.receivedTransfers.isEmpty,
            "Repository.transfer should not be called when contact cannot be resolved."
        )
        XCTAssertTrue(
            notificationSpy.successAmounts.isEmpty,
            "No success notification should be scheduled for unknown error."
        )
    }
    func test_performTransfer_whenRepositoryThrowsTransferError_propagatesSameError() async throws {
        // GIVEN – repositório configurado para lançar insufficientBalance
        let repoError: TransferError = .insufficientBalance
        let (sut, walletRepo, _, notificationSpy, beneficiary, amount) = makeSUT(
            isAuthorized: true,
            repoErrorToThrow: repoError
        )

        // WHEN / THEN
        do {
            try await sut.performTransfer(to: beneficiary, amount: amount)
            XCTFail("Expected performTransfer to propagate TransferError from repository.")
        } catch let error as TransferError {
            XCTAssertEqual(error, repoError)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }

        XCTAssertEqual(walletRepo.receivedTransfers.count, 1, "Repository.transfer should still be called once.")
        XCTAssertTrue(notificationSpy.successAmounts.isEmpty, "No success notification should be scheduled when repository fails.")
    }
}

// MARK: - Test Doubles

private final class WalletRepositorySpy: WalletRepository {

    private(set) var balance: Decimal
    private let storedContacts: [Contact]

    init(contacts: [Contact], balance: Decimal) {
        self.storedContacts = contacts
        self.balance = balance
    }

    private(set) var receivedTransfers: [(contact: Contact, amount: Decimal)] = []

    var errorToThrow: Error?

    func getBalance() -> Decimal {
        balance
    }

    func getContacts() -> [Contact] {
        storedContacts
    }

    func transfer(to contact: Contact, amount: Decimal) throws {
        receivedTransfers.append((contact, amount))
        balance -= amount

        if let errorToThrow {
            throw errorToThrow
        }
    }
}

private struct AuthorizationServiceStub: AuthorizationService {
    let result: AuthorizationResult

    func authorize(amount: Decimal) async -> AuthorizationResult {
        result
    }
}

private final class NotificationSchedulerSpy: LocalNotificationScheduler {

    private(set) var successAmounts: [Decimal] = []

    func scheduleSuccessNotification(for amount: Decimal) {
        successAmounts.append(amount)
    }

    func scheduleAuthorizationReminder() {
        // Not needed for these tests
    }
}

private final class DummyAuthRepository: AuthRepository {
    func login(email: String, password: String) throws -> PaymentWallet.User {
        // Return a harmless placeholder user.
        return PaymentWallet.User(
            id: UUID(),
            name: "Dummy",
            email: "dummy@example.com"
        )
    }
}

private final class DummyAuthTokenStore: AuthTokenStore {
    func save(token: String) {
        // Intentionally left empty.
    }
    
    func get() -> String? {
        // Return nil as a placeholder.
        return nil
    }
    
    func clear() {
        // Intentionally left empty.
    }
}
