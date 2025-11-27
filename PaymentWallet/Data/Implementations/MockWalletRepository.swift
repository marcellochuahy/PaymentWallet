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
        Contact(name: "Ludwig van Beethoven", email: "ludwig@example.com", accountDescription: "Conta corrente: R$ 1.804,37"),
        Contact(name: "Clara Schumann", email: "clara@example.com", accountDescription: "Poupança: R$ 1.841,56"),
        Contact(name: "Hildegard von Bingen", email: "hildegard@example.com", accountDescription: "Conta do mosteiro: R$ 1.151,49")
    ]

    // MARK: - Methods

    func getBalance() -> Decimal {
        balance
    }

    func getContacts() -> [Contact] {
        contacts
    }
}
