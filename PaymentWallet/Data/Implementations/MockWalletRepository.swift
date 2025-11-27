//
//  MockWalletRepository.swift
//  PaymentWallet
//
//  Created by Marcello Chuahy on 25/11/25.
//

import Foundation

final class MockWalletRepository: WalletRepository {
    
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

    /// Returns the current mock balance.
    func getBalance() -> Decimal {
        balance
    }

    /// Returns a static list of mock contacts.
    func getContacts() -> [Contact] {
        contacts
    }

    /// Simulates a successful money transfer by subtracting the amount
    /// from the in-memory balance.
    ///
    /// - Parameters:
    ///   - contact: The destination contact of the transfer.
    ///   - amount: The amount to be transferred.
    ///
    /// - Note: This mock implementation never throws.
    func transfer(to contact: Contact, amount: Decimal) throws {
        balance -= amount
    }
    
}
