//
//  HomeCoordinator.swift
//  PaymentWallet
//
//  Created by Marcello Chuahy on 25/11/25.
//

import UIKit
import SwiftUI
import WalletFeature

// MARK: - HomeCoordinator

final class HomeCoordinator {

    // MARK: - Properties

    private let navigationController: UINavigationController
    private let dependencies: AppDependencies

    /// Keeps a strong reference to the transfer flow coordinator
    /// while the transfer screen is on the stack.
    private var transferCoordinator: TransferCoordinator?

    // MARK: - Initializers

    init(navigationController: UINavigationController, dependencies: AppDependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }

    // MARK: - Public Methods

    func start() {
        let userInfo = WalletFeatureEntryPoint.UserInfo(
            name: "Wolfgang Amadeus Mozart",
            email: "user@example.com"
        )

        let homeView = WalletFeatureEntryPoint.makeHomeView(
            user: userInfo,
            loadBalance: { [dependencies] in
                dependencies.walletRepository.getBalance()
            },
            loadContacts: { [dependencies] in
                dependencies.walletRepository
                    .getContacts()
                    .map { contact in
                        WalletFeatureEntryPoint.Contact(
                            id: contact.id,
                            name: contact.name,
                            email: contact.email,
                            accountDescription: contact.accountDescription
                        )
                    }
            },
            onSelectContact: { [weak self] contact in
                
                guard let self else { return }
                
                // Start the Transfer flow pre-selecting this contact.
                let transferCoordinator = TransferCoordinator(navigationController: self.navigationController, dependencies: self.dependencies)

                // Keep a strong reference while the flow is active.
                self.transferCoordinator = transferCoordinator

                transferCoordinator.start(preselectedContact: contact)
            }
        )

        let hosting = UIHostingController(rootView: homeView)
        hosting.title = NSLocalizedString("home.title", comment: "Home screen title")
        navigationController.setViewControllers([hosting], animated: true)
    }
}
