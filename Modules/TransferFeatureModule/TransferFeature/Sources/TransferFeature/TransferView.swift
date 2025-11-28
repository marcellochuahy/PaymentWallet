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
                        .accessibilityHint("Escolha o destinatário da transferência.")
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
                            .accessibilityLabel(Text(error))
                            .accessibilityHint(LocalizedStringKey("transfer.a11y.errorMessage.hint"))
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
                                .accessibilityLabel(LocalizedStringKey("transfer.a11y.loading"))
                        } else {
                            Text(
                                NSLocalizedString("transfer.button.submit", comment: "Submit transfer button")
                            )
                            .font(.headline)
                        }
                    }
                    .disabled(viewModel.isLoading)
                    .accessibilityHint(LocalizedStringKey("transfer.a11y.submitButton.hint"))
                }
            }
            .navigationTitle(
                NSLocalizedString("transfer.title", comment: "Transfer screen title")
            )
            .accessibilityElement(children: .contain)
        }
    }
}

#if DEBUG
// MARK: - Preview Helpers

/// Simple preview error type used to simulate failures in the preview.
private struct PreviewTransferError: LocalizedError {
    let message: String

    var errorDescription: String? { message }
}

/// Mock that simulates a successful transfer.
private func previewPerformTransferSuccess(
    _: TransferFeatureEntryPoint.Beneficiary,
    _: Decimal
) async throws {
    // Small delay to visualize loading state if needed
    try? await Task.sleep(nanoseconds: 400_000_000)
}

/// Mock que sempre falha (ex.: saldo insuficiente / operação não permitida).
private func previewPerformTransferFailure(
    _: TransferFeatureEntryPoint.Beneficiary,
    _: Decimal
) async throws {
    throw PreviewTransferError(message: "Operation not allowed in preview mode.")
}

// MARK: - Beneficiaries mock

private extension TransferFeatureEntryPoint.Beneficiary {
    static var previewList: [TransferFeatureEntryPoint.Beneficiary] {
        [
            .init(
                id: UUID(),
                name: "Ludwig van Beethoven",
                accountDescription: "Conta corrente • 1234-5"
            ),
            .init(
                id: UUID(),
                name: "Clara Schumann",
                accountDescription: "Poupança • 9876-0"
            ),
            .init(
                id: UUID(),
                name: "Hildegard von Bingen",
                accountDescription: "Mosteiro • 0001-0"
            )
        ]
    }
}

// MARK: - Previews

#Preview("Transfer – Success (Light)") {
    let vm = TransferViewModel(
        beneficiaries: TransferFeatureEntryPoint.Beneficiary.previewList,
        performTransfer: previewPerformTransferSuccess
    )
    vm.amountText = "150,00"

    return TransferView(
        viewModel: vm,
        onTransferSuccess: {}
    )
}

#Preview("Transfer – Success (Dark)") {
    let vm = TransferViewModel(
        beneficiaries: TransferFeatureEntryPoint.Beneficiary.previewList,
        performTransfer: previewPerformTransferSuccess
    )
    vm.amountText = "99,90"

    return TransferView(
        viewModel: vm,
        onTransferSuccess: {}
    )
    .preferredColorScheme(.dark)
}

#Preview("Transfer – Error state") {
    let vm = TransferViewModel(
        beneficiaries: TransferFeatureEntryPoint.Beneficiary.previewList,
        performTransfer: previewPerformTransferFailure
    )
    vm.amountText = "403"

    return TransferView(
        viewModel: vm,
        onTransferSuccess: {}
    )
}
#endif
