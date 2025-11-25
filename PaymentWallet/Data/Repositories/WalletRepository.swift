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
protocol WalletRepository {
    /// Returns the balance for the authenticated user.
    func getBalance() -> Decimal

    /// Returns the mocked list of contacts available for transfers.
    func getContacts() -> [Contact]
}
