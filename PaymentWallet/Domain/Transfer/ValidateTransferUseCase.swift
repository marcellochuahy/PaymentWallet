//
//  ValidateTransferUseCase.swift
//  PaymentWallet
//
//  Created by Marcello Chuahy on 25/11/25.
//

import Foundation

/// Business errors associated with transfer validation.
/// Each case represents a rule violation that prevents the transfer from being executed.
enum TransferValidationError: Error, Equatable {
    case amountMustBeGreaterThanZero
    case insufficientBalance
    case payerAndPayeeMustBeDifferent
}

/// Transfer validation use case protocol.
/// Designed for dependency injection and testability.
/// The concrete implementation is stateless and pure, allowing deterministic unit tests.
protocol ValidateTransferUseCaseProtocol {
    /// Validates whether a transfer operation is allowed, based on business rules.
    ///
    /// - Parameters:
    ///   - payer: The user who is sending the money.
    ///   - payee: The contact receiving the money.
    ///   - amount: The transfer amount.
    ///   - currentBalance: The current balance of the payer.
    ///
    /// - Throws: `TransferValidationError` when any business rule is violated.
    func execute(
        payer: User,
        payee: Contact,
        amount: Decimal,
        currentBalance: Decimal
    ) throws
}

/// Concrete implementation of the transfer validation use case.
/// Contains the core business logic that enforces transfer rules:
/// - Amount must be greater than zero.
/// - Payer cannot be the same as payee.
/// - User must have sufficient balance.
final class ValidateTransferUseCase: ValidateTransferUseCaseProtocol {

    func execute(
        payer: User,
        payee: Contact,
        amount: Decimal,
        currentBalance: Decimal
    ) throws {

        // Rule 1: Transfer amount must be strictly greater than zero.
        if amount <= 0 {
            throw TransferValidationError.amountMustBeGreaterThanZero
        }

        // Rule 2: Payer and payee must be different users.
        // The email is used as unique identifier for this challenge.
        if payer.email == payee.email {
            throw TransferValidationError.payerAndPayeeMustBeDifferent
        }

        // Rule 3: Ensure the payer has enough funds to complete the transfer.
        if amount > currentBalance {
            throw TransferValidationError.insufficientBalance
        }

        // If none of the above rules triggered an error,
        // then the transfer is considered valid.
    }
}
