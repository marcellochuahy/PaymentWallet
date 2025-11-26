//
//  WalletFeatureEntryPoint.swift
//  Pods-PaymentWallet
//
//  Created by Marcello Chuahy on 25/11/25.
//

import SwiftUI

// MARK: - WalletFeatureEntryPoint

/// Entry point for the WalletFeature module.
public enum WalletFeatureEntryPoint {

    /// Public DTO for user info displayed on Home.
    public struct UserInfo {
        public let name: String
        public let email: String

        public init(name: String, email: String) {
            self.name = name
            self.email = email
        }
    }

    /// Public DTO for contacts displayed on Home.
    public struct Contact: Identifiable {
        public let id: UUID
        public let name: String

        public init(id: UUID = UUID(), name: String) {
            self.id = id
            self.name = name
        }
    }

    /// Factory to create the HomeView.
    ///
    /// - Parameters:
    ///   - user: basic info of the logged user.
    ///   - loadBalance: closure that returns the current balance.
    ///   - loadContacts: closure that returns the list of contacts.
    ///   - onSelectContact: called when user taps a contact.
    @MainActor
    public static func makeHomeView(
        user: UserInfo,
        loadBalance: @escaping () -> Decimal,
        loadContacts: @escaping () -> [Contact],
        onSelectContact: @escaping (Contact) -> Void
    ) -> some View {
        let viewModel = HomeViewModel(
            user: user,
            loadBalance: loadBalance,
            loadContacts: loadContacts,
            onSelectContact: onSelectContact
        )
        return HomeView(viewModel: viewModel)
    }
}
