//
//  TransferCoordinator.swift
//  PaymentWallet
//
//  Created by Marcello Chuahy on 26/11/25.
//

import UIKit
import SwiftUI
import WalletFeature
import TransferFeature

// MARK: - TransferCoordinator

/// Coordinates the money transfer flow using the TransferFeature module.
final class TransferCoordinator {

    // MARK: - Properties

    private let navigationController: UINavigationController
    private let dependencies: AppDependencies

    // MARK: - Initializer

    init(
        navigationController: UINavigationController,
        dependencies: AppDependencies
    ) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }

    // MARK: - Public API

    /// Starts the Transfer flow by pushing the SwiftUI TransferView
    /// wrapped in a UIHostingController.
    ///
    /// - Parameter preselectedContact:
    ///   Optional contact coming from the Home screen. If provided,
    ///   it will be used to preselect the beneficiary in the transfer form.
    @MainActor
    func start(preselectedContact: WalletFeatureEntryPoint.Contact? = nil) {
        
        // 1) Load contacts from the WalletRepository and map to Beneficiary DTOs.
        let contacts = dependencies.walletRepository.getContacts()

        let beneficiaries: [TransferFeatureEntryPoint.Beneficiary] = contacts.map { contact in
            TransferFeatureEntryPoint.Beneficiary(
                id: contact.id,
                name: contact.name,
                accountDescription: contact.accountDescription
            )
        }

        let preselectedID = preselectedContact?.id

        // 2) Build the SwiftUI view using the feature entry point.
        let transferView = TransferFeatureEntryPoint.makeTransferView(
            beneficiaries: beneficiaries,
            preselectedBeneficiaryID: preselectedID,
            performTransfer: { [weak self] beneficiary, amount in
                guard let self else { return }
                try await self.performTransfer(beneficiary: beneficiary, amount: amount)
            },
            onTransferSuccess: { [weak self] in
                self?.handleTransferSuccess()
            }
        )

        // 3) Wrap in UIHostingController and push into the navigation stack.
        let hosting = UIHostingController(rootView: transferView)
        hosting.title = "Transfer" // podemos traduzir depois via Localizable

        navigationController.pushViewController(hosting, animated: true)
    }

    // MARK: - Private helpers

    /// Bridges the feature's `performTransfer` dependency to the SuperApp layer.
    /// Here we can:
    /// - Call the AuthorizationService to approve the transfer.
    /// - Optionally call the WalletRepository to persist / sync the transfer.
    /// - Schedule local notifications.
    @MainActor
    private func performTransfer(
        beneficiary: TransferFeatureEntryPoint.Beneficiary,
        amount: Decimal
    ) async throws {

        // 1) Ask for authorization.
        let result = await dependencies.authorizationService.authorize(amount: amount)

        guard result.isAuthorized else {
            // If not authorized, schedule a reminder and throw
            dependencies.notificationScheduler.scheduleAuthorizationReminder()
            throw TransferError.notAuthorized(reason: result.reason)
        }

        // 2) (Optional) Here we could register/log the transfer using walletRepository
        // For the coding challenge we will just schedule a success notification.
        dependencies.notificationScheduler.scheduleSuccessNotification(for: amount)
    }

    /// Called when the Transfer feature reports a successful operation.
    @MainActor
    private func handleTransferSuccess() {
        // For now, simply pop back to the previous screen.
        navigationController.popViewController(animated: true)
    }
}

// MARK: - Internal Error Type

/// Local error type used by the coordinator to represent domain-level failures.
enum TransferError: Error, Equatable {
    case notAuthorized(reason: String?)
}
