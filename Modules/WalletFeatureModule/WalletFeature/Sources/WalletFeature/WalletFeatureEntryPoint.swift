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

    // MARK: - Factory

    /// Factory that builds the HomeView wrapped with its ViewModel.
    ///
    /// - Parameters:
    ///   - user: basic user info (name + email).
    ///   - loadBalance: closure that returns the current balance.
    ///   - loadContacts: closure that returns contacts mapped to `Contact` DTOs.
    ///   - onSelectContact: callback invoked when the user taps a contact in the list.
    @MainActor
    public static func makeHomeView(user: UserInfoDataTransfer,
                                    loadBalance: @escaping () -> Decimal,
                                    loadContacts: @escaping () -> [ContactDataTransfer],
                                    onSelectContact: @escaping (ContactDataTransfer) -> Void) -> some View {

        let viewModel = HomeViewModel(user: user,
                                      loadBalance: loadBalance,
                                      loadContacts: loadContacts,
                                      onSelectContact: onSelectContact)

        return HomeView(viewModel: viewModel)
    }
    
}
