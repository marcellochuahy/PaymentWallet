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

/// Coordinator responsible for driving the transfer flow:
/// - builds the TransferFeature SwiftUI view;
/// - connects it to the domain (WalletRepository + AuthorizationService);
/// - schedules local notifications on success.
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

    /// Starts the transfer flow using the given contact as the initial selection.
    ///
    /// - Parameter preselectedContact: Contact selected in Home (WalletFeature DTO).
    func start(preselectedContact: ContactDataTransfer) {
 
        // 1) Load domain contacts from the repository.
        let domainContacts = dependencies.walletRepository.getContacts()

        // 2) Map domain contacts into TransferFeature DTOs (Beneficiary).
        let beneficiaries: [TransferFeatureEntryPoint.Beneficiary] = domainContacts.map {
            TransferFeatureEntryPoint.Beneficiary(
                id: $0.id,
                name: $0.name,
                accountDescription: $0.accountDescription
            )
        }

        // 3) Pre-select the beneficiary that matches the tapped contact.
        let preselectedID = preselectedContact.id

        let transferView = TransferFeatureEntryPoint.makeTransferView(
            beneficiaries: beneficiaries,
            preselectedBeneficiaryID: preselectedID,
            performTransfer: { [weak self] beneficiary, amount in
                guard let self else { return }
                try await self.performTransfer(to: beneficiary, amount: amount)
            },
            onTransferSuccess: { [weak self] in
                print("4️⃣ [TransferCoordinator] transfer completed successfully")
                // For now, we simply pop back to Home.
                self?.navigationController.popViewController(animated: true)
            }
        )

        let hosting = UIHostingController(rootView: transferView)
        hosting.title = NSLocalizedString("transfer.title", comment: "Transfer screen title")

        navigationController.pushViewController(hosting, animated: true)
    }

    // MARK: - Private helpers

    /// Orchestrates the transfer:
    /// - asks the AuthorizationService to authorize the operation;
    /// - maps the beneficiary DTO back to the domain Contact;
    /// - calls the WalletRepository to perform the transfer;
    /// - schedules a local notification on success.
    @MainActor
    func performTransfer(
        to beneficiary: TransferFeatureEntryPoint.Beneficiary,
        amount: Decimal
    ) async throws {

        // 1) Ask the mock AuthorizationService if this amount is allowed.
        let authResult = await dependencies.authorizationService.authorize(amount: amount)

        guard authResult.isAuthorized else {
            // Map denial to a domain error that the UI can present as a friendly message.
            throw TransferError.notAuthorized(reason: authResult.reason)
        }

        // 2) Resolve the domain Contact that matches the chosen beneficiary.
        guard let contact = dependencies.walletRepository
            .getContacts()
            .first(where: { $0.id == beneficiary.id }) else {
            throw TransferError.unknown
        }

        // 3) Perform the transfer in the repository.
        do {
            try dependencies.walletRepository.transfer(to: contact, amount: amount)
        } catch let transferError as TransferError {
            // If the repository already throws TransferError, just propagate it.
            throw transferError
        } catch {
            // Any other error is mapped to a generic domain error.
            throw TransferError.unknown
        }

        // 4) Schedule local notification for the authorized transfer.
        dependencies.notificationScheduler.scheduleSuccessNotification(for: amount)
    }
    
}
