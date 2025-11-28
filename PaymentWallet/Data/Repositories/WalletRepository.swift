//
//  WalletRepository.swift
//  PaymentWallet
//
//  Created by Marcello Chuahy on 25/11/25.
//

import Foundation

// MARK: - WalletRepository

/// Repository responsible for retrieving user balance and contact list.
/// All data is mocked locally in this challenge.
///
/// Implementations may also support persistence, authorization checks,
/// notifications and dynamic updates depending on the domain needs.
protocol WalletRepository {
    
    /// Returns the balance for the authenticated user.
    func getBalance() -> Decimal

    /// Returns the mocked list of contacts available for transfers.
    func getContacts() -> [Contact]
    
    /// Executes a money transfer operation.
    ///
    /// - Parameters:
    ///   - contact: The beneficiary of the transfer (domain model, not DTO).
    ///   - amount: The amount to transfer.
    ///
    /// - Throws: An error if the transfer cannot be completed, such as:
    ///   - `TransferError.insufficientBalance` when the amount exceeds the balance
    ///   - Other domain errors depending on the concrete implementation
    func transfer(to contact: Contact, amount: Decimal) throws
}
