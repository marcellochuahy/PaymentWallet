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
    ///   - amount: The amount to transfer. Must be validated by the caller.
    ///
    /// - Throws: An error if the transfer cannot be completed.
    ///
    /// Concrete implementations should update the internal balance
    /// and optionally persist the transaction. For example, a mock
    /// implementation may simply subtract the amount from an in-memory
    /// value, whereas a real implementation may store the transaction
    /// in a database or synchronize with a backend.
    func transfer(to contact: Contact, amount: Decimal) throws
    
}
