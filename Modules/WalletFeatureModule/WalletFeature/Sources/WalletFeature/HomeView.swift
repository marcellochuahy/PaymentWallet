//
//  HomeView.swift
//  Pods-PaymentWallet
//
//  Created by Marcello Chuahy on 25/11/25.
//

import SwiftUI

// MARK: - HomeView

/// Home screen showing basic user info, balance, and contact list.
/// All user-facing strings are localized.
public struct HomeView: View {

    @StateObject private var viewModel: HomeViewModel

    public init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        NavigationView {
            List {
                Section(LocalizedStringKey("home.section.user")) {
                    Text(viewModel.userName)
                        .font(.headline)

                    Text(viewModel.userEmail)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Section(LocalizedStringKey("home.section.balance")) {
                    Text(viewModel.balanceText)
                        .font(.title2.bold())
                }

                Section(LocalizedStringKey("home.section.contacts")) {

                    if viewModel.contacts.isEmpty {
                        Text(LocalizedStringKey("home.contacts.empty"))
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(viewModel.contacts) { contact in
                            Button(action: {
                                viewModel.didTap(contact: contact)
                            }) {
                                Text(contact.name)
                            }
                        }
                    }
                }
            }
            .navigationTitle(LocalizedStringKey("home.title"))
        }
        .onAppear {
            viewModel.loadData()
        }
    }
}
