//
//  TransferViewModel.swift
//  TransferFeature
//
//  Created by Marcello Chuahy on 26/11/25.
//

import Foundation

/// ViewModel responsible for handling the money transfer flow.
/// It validates user input, parses the amount using pt_BR locale
/// and delegates the actual transfer to an async dependency.
@MainActor
public final class TransferViewModel: ObservableObject {

    // MARK: - Published Properties

    /// Currently selected beneficiary ID in the UI Picker.
    @Published public var selectedBeneficiaryID: TransferFeatureEntryPoint.Beneficiary.ID?

    /// Raw amount text typed by the user (e.g. "1.234,56").
    @Published public var amountText: String = ""

    /// Indicates whether a transfer is currently being submitted.
    @Published public private(set) var isLoading: Bool = false

    /// Optional error message to be shown in the UI.
    @Published public private(set) var errorMessage: String?

    // MARK: - Dependencies

    /// List of available beneficiaries (coming from the host app).
    public let beneficiaries: [TransferFeatureEntryPoint.Beneficiary]

    /// Performs the actual transfer.
    /// - Parameters:
    ///   - beneficiary: validated beneficiary DTO.
    ///   - amount: validated transfer amount.
    private let performTransfer: @Sendable (TransferFeatureEntryPoint.Beneficiary, Decimal) async throws -> Void

    // MARK: - Initializer

    public init(
        beneficiaries: [TransferFeatureEntryPoint.Beneficiary],
        preselectedBeneficiaryID: TransferFeatureEntryPoint.Beneficiary.ID? = nil,
        performTransfer: @escaping @Sendable (TransferFeatureEntryPoint.Beneficiary, Decimal) async throws -> Void
    ) {
        self.beneficiaries = beneficiaries
        self.performTransfer = performTransfer

        // If a preselected ID is provided and exists in the list, use it.
        // Otherwise, fall back to the first beneficiary if available.
        if let preselectedBeneficiaryID,
           beneficiaries.contains(where: { $0.id == preselectedBeneficiaryID }) {
            self.selectedBeneficiaryID = preselectedBeneficiaryID
        } else {
            self.selectedBeneficiaryID = beneficiaries.first?.id
        }
    }

    // MARK: - Public Methods

    /// Validates the input, parses the amount and calls `performTransfer`.
    /// If everything goes well, calls `onSuccess`.
    public func submitTransfer(onSuccess: @escaping () -> Void) async {

        // Snapshot values to avoid data races under Swift 6 strict concurrency.
        let selectedID = selectedBeneficiaryID
        let amountTextSnapshot = amountText

        // Validate selection
        guard let selectedID else {
            errorMessage = NSLocalizedString("transfer.error.noBeneficiary", comment: "No beneficiary selected error")
            return
        }

        guard let selectedBeneficiary = beneficiaries.first(where: { $0.id == selectedID }) else {
            errorMessage = NSLocalizedString("transfer.error.invalidBeneficiary", comment: "Invalid beneficiary error")
            return
        }

        // Validate amount
        guard let amount = Self.parseAmount(from: amountTextSnapshot) else {
            errorMessage = NSLocalizedString("transfer.error.invalidAmount", comment: "Invalid amount error")
            return
        }

        guard amount > 0 else {
            errorMessage = NSLocalizedString("transfer.error.amountGreaterThanZero", comment: "Amount must be greater than zero")
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            try await performTransfer(selectedBeneficiary, amount)
            isLoading = false
            onSuccess()
        }
        catch let error as LocalizedError {
            isLoading = false
            errorMessage = error.errorDescription
                ?? NSLocalizedString("transfer.error.unexpected", comment: "Unexpected transfer error")
        }
        catch {
            isLoading = false
            errorMessage = NSLocalizedString("transfer.error.unexpected", comment: "Unexpected transfer error")
        }
    }

    // MARK: - Helpers

    /// Parses a user-facing currency string into Decimal using pt_BR locale.
    /// Accepts formats like:
    /// - "1.234,56"
    /// - "1234,56"
    /// - "1234.56"
    static func parseAmount(from text: String) -> Decimal? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "pt_BR")

        // 1) First try parsing using pt_BR locale.
        if let number = formatter.number(from: trimmed) {
            return number.decimalValue
        }

        // 2) Fallback: comma-decimal normalization.
        if trimmed.contains(",") {
            let normalized = trimmed
                .replacingOccurrences(of: ".", with: "")
                .replacingOccurrences(of: ",", with: ".")
            return Decimal(string: normalized)
        } else {
            // 3) Standard dot-decimal fallback.
            return Decimal(string: trimmed)
        }
    }
}
