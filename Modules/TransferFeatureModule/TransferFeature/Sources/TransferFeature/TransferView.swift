//
//  TransferView.swift
//  TransferFeature
//
//  Created by Marcello Chuahy on 26/11/25.
//

import SwiftUI

// MARK: - TransferView

/// Simple transfer form: beneficiary picker + amount + submit button.
@MainActor
public struct TransferView: View {

    @StateObject private var viewModel: TransferViewModel
    private let onTransferSuccess: () -> Void

    // MARK: - Initializer

    public init(
        viewModel: TransferViewModel,
        onTransferSuccess: @escaping () -> Void
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onTransferSuccess = onTransferSuccess
    }

    // MARK: - Body

    public var body: some View {
        NavigationView {
            Form {

                // MARK: Beneficiary
                Section(
                    NSLocalizedString("transfer.section.beneficiary", comment: "Beneficiary section title")
                ) {
                    if viewModel.beneficiaries.isEmpty {
                        Text(NSLocalizedString("transfer.noBeneficiaries", comment: "No beneficiaries available"))
                            .foregroundStyle(.secondary)

                    } else {
                        Picker(
                            NSLocalizedString("transfer.selectBeneficiary", comment: "Select beneficiary label"),
                            selection: $viewModel.selectedBeneficiaryID
                        ) {
                            ForEach(viewModel.beneficiaries) { beneficiary in
                                VStack(alignment: .leading) {
                                    Text(beneficiary.name)
                                    Text(beneficiary.accountDescription)
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                                .tag(beneficiary.id as TransferFeatureEntryPoint.Beneficiary.ID?)
                            }
                        }
                    }
                }

                // MARK: Amount
                Section(
                    NSLocalizedString("transfer.section.amount", comment: "Amount section title")
                ) {
                    TextField(
                        NSLocalizedString("transfer.placeholder.amount", comment: "Amount placeholder"),
                        text: $viewModel.amountText
                    )
                    .keyboardType(.decimalPad)
                }

                // MARK: Error
                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundStyle(Color.red)
                            .font(.callout)
                    }
                }

                // MARK: Submit
                Section {
                    Button {
                        Task {
                            await viewModel.submitTransfer(onSuccess: onTransferSuccess)
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Text(
                                NSLocalizedString("transfer.button.submit", comment: "Submit transfer button")
                            )
                            .font(.headline)
                        }
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .navigationTitle(
                NSLocalizedString("transfer.title", comment: "Transfer screen title")
            )
        }
    }
}
