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
                            .accessibilityHint(LocalizedStringKey("home.a11y.contacts.empty.hint"))
                    } else {
                        ForEach(viewModel.contacts) { contact in
                            Button(action: {
                                viewModel.didTap(contact: contact)
                            }) {
                                Text(contact.name)
                            }
                            .accessibilityHint(LocalizedStringKey("home.a11y.contactButton.hint"))
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

#if DEBUG

// MARK: - Preview helpers

private extension UserInfoDataTransfer {
    static var preview: UserInfoDataTransfer {
        .init(
            name: "Johann Sebastian Bach",
            email: "johann@illbebach.com"
        )
    }
}

private extension Array where Element == ContactDataTransfer {
    static var previewContacts: [ContactDataTransfer] {
        [
            .init(
                id: UUID(),
                name: "Ludwig van Beethoven",
                email: "ludwig@example.com",
                accountDescription: "Conta corrente • 1234-5"
            ),
            .init(
                id: UUID(),
                name: "Clara Schumann",
                email: "clara@example.com",
                accountDescription: "Poupança • 9876-0"
            ),
            .init(
                id: UUID(),
                name: "Hildegard von Bingen",
                email: "hildegard@example.com",
                accountDescription: "Mosteiro • 0001-0"
            )
        ]
    }

    static var emptyContacts: [ContactDataTransfer] {
        []
    }
}

// MARK: - Previews

#Preview("Home – Default (Light)") {
    let user = UserInfoDataTransfer.preview
    let viewModel = HomeViewModel(
        user: user,
        loadBalance: { 1_234.56 },
        loadContacts: { .previewContacts },
        onSelectContact: { _ in }
    )

    return HomeView(viewModel: viewModel)
}

#Preview("Home – Default (Dark)") {
    let user = UserInfoDataTransfer.preview
    let viewModel = HomeViewModel(
        user: user,
        loadBalance: { 9_999.99 },
        loadContacts: { .previewContacts },
        onSelectContact: { _ in }
    )

    return HomeView(viewModel: viewModel)
        .preferredColorScheme(.dark)
}

#Preview("Home – Empty contacts") {
    let user = UserInfoDataTransfer.preview
    let viewModel = HomeViewModel(
        user: user,
        loadBalance: { 0.0 },
        loadContacts: { .emptyContacts },
        onSelectContact: { _ in }
    )

    return HomeView(viewModel: viewModel)
}

#endif
