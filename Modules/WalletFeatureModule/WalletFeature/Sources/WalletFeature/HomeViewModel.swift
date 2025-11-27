//
//  HomeViewModel.swift
//  Pods-PaymentWallet
//
//  Created by Marcello Chuahy on 25/11/25.
//

import Foundation
import Combine

// MARK: - HomeViewModel

/// ViewModel that exposes the user info, balance and contacts for the Home screen.
@MainActor
public final class HomeViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published public private(set) var userName: String
    @Published public private(set) var userEmail: String
    @Published public private(set) var balanceText: String = "R$ 0,00"
    @Published public private(set) var contacts: [ContactDataTransfer] = []

    // MARK: - Dependencies

    private let loadBalance: () -> Decimal
    private let loadContactsClosure: () -> [ContactDataTransfer]
    private let onSelectContact: (ContactDataTransfer) -> Void

    // MARK: - Initializers

    public init(
        user: UserInfoDataTransfer,
        loadBalance: @escaping () -> Decimal,
        loadContacts: @escaping () -> [ContactDataTransfer],
        onSelectContact: @escaping (ContactDataTransfer) -> Void
    ) {
        self.userName = user.name
        self.userEmail = user.email
        self.loadBalance = loadBalance
        self.loadContactsClosure = loadContacts
        self.onSelectContact = onSelectContact
    }

    // MARK: - Public Methods

    public func loadData() {
        let balance = loadBalance()
        balanceText = Self.formatCurrency(balance)
        contacts = loadContactsClosure()
    }

    public func didTap(contact: ContactDataTransfer) {
        onSelectContact(contact)
    }

    // MARK: - Helpers

    private static func formatCurrency(_ value: Decimal) -> String {
        let number = value as NSDecimalNumber
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: number) ?? "R$ \(value)"
    }
}
