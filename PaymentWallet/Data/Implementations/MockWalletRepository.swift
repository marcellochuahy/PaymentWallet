//
//  MockWalletRepository.swift
//  PaymentWallet
//
//  Created by Marcello Chuahy on 25/11/25.
//

import Foundation

// MARK: - MockWalletRepository

final class MockWalletRepository: WalletRepository {

    // MARK: - Properties

    private let balance: Decimal = 350

    private let contacts: [Contact] = [
        Contact(name: "Ludwig van Beethoven", email: "ludwig@example.com"),
        Contact(name: "Clara Schumann", email: "clara@example.com"),
        Contact(name: "Hildegard von Bingen", email: "hildegard@example.com")
    ]

    // MARK: - Methods

    func getBalance() -> Decimal {
        balance
    }

    func getContacts() -> [Contact] {
        contacts
    }
}
