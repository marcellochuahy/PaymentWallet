//
//  WalletFeatureEntryPoint.swift
//  Pods-PaymentWallet
//
//  Created by Marcello Chuahy on 25/11/25.
//

import SwiftUI

// MARK: - WalletFeatureEntryPoint

/// Public entry point for the WalletFeature module.
public enum WalletFeatureEntryPoint {

    // MARK: - DTOs

    public struct UserInfo: Equatable, Sendable {
        public let name: String
        public let email: String

        public init(name: String, email: String) {
            self.name = name
            self.email = email
        }
    }

    public struct Contact: Identifiable, Equatable, Sendable {
        public let id: UUID
        public let name: String
        public let email: String
        public let accountDescription: String

        /// Full initializer used by the Super App (with all fields).
        public init(
            id: UUID = UUID(),
            name: String,
            email: String,
            accountDescription: String
        ) {
            self.id = id
            self.name = name
            self.email = email
            self.accountDescription = accountDescription
        }

    }

    // MARK: - Factory

    /// Factory that builds the HomeView wrapped with its ViewModel.
        ///
        /// - Parameters:
        ///   - user: basic user info (name + email).
        ///   - loadBalance: closure that returns the current balance.
        ///   - loadContacts: closure that returns contacts mapped to `Contact` DTOs.
        ///   - onSelectContact: callback invoked when the user taps a contact in the list.
        @MainActor
        public static func makeHomeView(
            user: UserInfo,
            loadBalance: @escaping () -> Decimal,
            loadContacts: @escaping () -> [Contact],
            onSelectContact: @escaping (Contact) -> Void
        ) -> some View {

            // Wrapper only to log that the callback reached the module.
            let wrappedOnSelect: (Contact) -> Void = { contact in
                onSelectContact(contact)
            }

            let viewModel = HomeViewModel(
                user: user,
                loadBalance: loadBalance,
                loadContacts: loadContacts,
                onSelectContact: wrappedOnSelect
            )

            return HomeView(viewModel: viewModel)
        }
    
}
