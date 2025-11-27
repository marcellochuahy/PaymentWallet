//
//  TransferFeatureEntryPoint.swift
//  TransferFeature
//
//  Created by Marcello Chuahy on 26/11/25.
//

import SwiftUI

// MARK: - TransferFeatureEntryPoint

/// Public entry point for the TransferFeature module.
public enum TransferFeatureEntryPoint {

    // MARK: - DTOs

    /// Public DTO representing a transfer beneficiary exposed to the host app.
    public struct Beneficiary: Identifiable, Equatable, Sendable {
        public let id: UUID
        public let name: String
        public let accountDescription: String

        public init(
            id: UUID = UUID(),
            name: String,
            accountDescription: String
        ) {
            self.id = id
            self.name = name
            self.accountDescription = accountDescription
        }
    }

    // MARK: - Factory

    /// Factory that builds the TransferView wrapped with its ViewModel.
    ///
    /// - Parameters:
    ///   - beneficiaries: list of possible transfer targets.
    ///   - preselectedBeneficiaryID: optional ID of a beneficiary that should
    ///     be preselected in the UI.
    ///   - performTransfer: async operation that executes the transfer.
    ///   - onTransferSuccess: callback called when transfer succeeds.
    @MainActor
    public static func makeTransferView(
        beneficiaries: [Beneficiary],
        preselectedBeneficiaryID: Beneficiary.ID? = nil,
        performTransfer: @escaping @Sendable (Beneficiary, Decimal) async throws -> Void,
        onTransferSuccess: @escaping () -> Void
    ) -> some View {

        let viewModel = TransferViewModel(
            beneficiaries: beneficiaries,
            preselectedBeneficiaryID: preselectedBeneficiaryID,
            performTransfer: performTransfer
        )

        return TransferView(
            viewModel: viewModel,
            onTransferSuccess: onTransferSuccess
        )
    }
}
