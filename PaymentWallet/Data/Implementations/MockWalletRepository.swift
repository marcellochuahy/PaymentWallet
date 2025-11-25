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
        Contact(name: "Alice Johnson", email: "alice@example.com"),
        Contact(name: "Bob Williams", email: "bob@example.com"),
        Contact(name: "Carol Smith", email: "carol@example.com")
    ]

    // MARK: - Methods

    func getBalance() -> Decimal {
        balance
    }

    func getContacts() -> [Contact] {
        contacts
    }
}
