//
//  HomeView.swift
//  Pods-PaymentWallet
//
//  Created by Marcello Chuahy on 25/11/25.
//

import SwiftUI

// MARK: - HomeView

/// Simple Home screen showing user name/email, balance and a basic contacts list.
public struct HomeView: View {

    @StateObject private var viewModel: HomeViewModel

    public init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        NavigationView {
            List {
                Section("User") {
                    Text(viewModel.userName)
                        .font(.headline)
                    Text(viewModel.userEmail)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Section("Balance") {
                    Text(viewModel.balanceText)
                        .font(.title2.bold())
                }

                Section("Contacts") {
                    if viewModel.contacts.isEmpty {
                        Text("No contacts available.")
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
            .navigationTitle("Home")
        }
        .onAppear {
            viewModel.loadData()
        }
    }
}
