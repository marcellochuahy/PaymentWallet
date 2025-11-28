//
//  MockWalletRepository.swift
//  PaymentWallet
//
//  Created by Marcello Chuahy on 25/11/25.
//

import Foundation

final class MockWalletRepository: WalletRepository {

    // MARK: - Internal state

    /// Internal in-memory balance used for mock transfers.
    private var balance: Decimal = 1200.50

    /// Stable in-memory contact list.
    /// IDs are created once and reused across all calls to `getContacts()`.
    private let contacts: [Contact] = [
        .init(
            id: UUID(),
            name: "Ludwig van Beethoven",
            email: "ludwig@example.com",
            accountDescription: "Conta corrente"
        ),
        .init(
            id: UUID(),
            name: "Clara Schumann",
            email: "clara@example.com",
            accountDescription: "Poupança"
        ),
        .init(
            id: UUID(),
            name: "Hildegard von Bingen",
            email: "hildegard@example.com",
            accountDescription: "Mosteiro"
        )
    ]

    // MARK: - Accessors

    func getBalance() -> Decimal {
        balance
    }

    func getContacts() -> [Contact] {
        contacts
    }

    // MARK: - Transfer logic

    /// Simulates a money transfer.
    /// Validates available balance before debiting.
    ///
    /// - Throws:
    ///   - TransferError.insufficientBalance when amount > balance.
    func transfer(to contact: Contact, amount: Decimal) throws {

        // 1) Validate sufficient balance
        guard amount <= balance else {
            throw TransferError.insufficientBalance
        }

        // 2) Simulate successful debit
        balance -= amount
    }
}
