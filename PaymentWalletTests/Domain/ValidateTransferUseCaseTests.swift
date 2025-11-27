//
//  ValidateTransferUseCaseTests.swift
//  PaymentWalletTests
//
//  Created by Marcello Chuahy on 25/11/25.
//

import XCTest
@testable import PaymentWallet

final class ValidateTransferUseCaseTests: XCTestCase {

    private var sut: ValidateTransferUseCase!
    private var payer: User!
    private var payee: Contact!
    private var currentBalance: Decimal!

    // MARK: - Lifecycle

    override func setUp() {
        super.setUp()
        sut = ValidateTransferUseCase()
        payer = User(name: "Payer User", email: "payer@example.com")
        payee = Contact(name: "Payee User", email: "payee@example.com", accountDescription: "")
        currentBalance = Decimal(100)
    }

    override func tearDown() {
        sut = nil
        payer = nil
        payee = nil
        currentBalance = nil
        super.tearDown()
    }

    // MARK: - Tests

    func test_givenValidTransfer_whenExecute_thenDoesNotThrow() {
        // given
        let amount = Decimal(50)

        // when / then
        XCTAssertNoThrow(
            try sut.execute(
                payer: payer,
                payee: payee,
                amount: amount,
                currentBalance: currentBalance
            )
        )
    }

    func test_givenZeroAmount_whenExecute_thenThrowsAmountMustBeGreaterThanZero() {
        // given
        let amount = Decimal(0)

        // when / then
        XCTAssertThrowsError(
            try sut.execute(
                payer: payer,
                payee: payee,
                amount: amount,
                currentBalance: currentBalance
            )
        ) { error in
            XCTAssertEqual(
                error as? TransferValidationError,
                .amountMustBeGreaterThanZero
            )
        }
    }

    func test_givenNegativeAmount_whenExecute_thenThrowsAmountMustBeGreaterThanZero() {
        // given
        let amount = Decimal(-10)

        // when / then
        XCTAssertThrowsError(
            try sut.execute(
                payer: payer,
                payee: payee,
                amount: amount,
                currentBalance: currentBalance
            )
        ) { error in
            XCTAssertEqual(
                error as? TransferValidationError,
                .amountMustBeGreaterThanZero
            )
        }
    }

    func test_givenPayerAndPayeeWithSameEmail_whenExecute_thenThrowsPayerAndPayeeMustBeDifferent() {
        // given
        let sameEmail = "user@example.com"
        payer = User(name: "User", email: sameEmail)
        payee = Contact(name: "User Contact", email: sameEmail, accountDescription: "")
        let amount = Decimal(10)

        // when / then
        XCTAssertThrowsError(
            try sut.execute(
                payer: payer,
                payee: payee,
                amount: amount,
                currentBalance: currentBalance
            )
        ) { error in
            XCTAssertEqual(
                error as? TransferValidationError,
                .payerAndPayeeMustBeDifferent
            )
        }
    }

    func test_givenAmountGreaterThanBalance_whenExecute_thenThrowsInsufficientBalance() {
        // given
        let amount = Decimal(150) // greater than 100

        // when / then
        XCTAssertThrowsError(
            try sut.execute(
                payer: payer,
                payee: payee,
                amount: amount,
                currentBalance: currentBalance
            )
        ) { error in
            XCTAssertEqual(
                error as? TransferValidationError,
                .insufficientBalance
            )
        }
    }

    func test_givenAmountEqualToBalance_whenExecute_thenDoesNotThrow() {
        // given
        let amount = currentBalance! // 100

        // when / then
        XCTAssertNoThrow(
            try sut.execute(
                payer: payer,
                payee: payee,
                amount: amount,
                currentBalance: currentBalance
            )
        )
    }
}
