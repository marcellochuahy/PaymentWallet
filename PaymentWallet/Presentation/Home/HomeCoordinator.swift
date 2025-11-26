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
                        WalletFeatureEntryPoint.Contact(name: contact.name)
                    }
            },
            onSelectContact: { contact in
                // Later this will start the transfer flow.
                print("Selected contact: \(contact.name)")
            }
        )

        let hosting = UIHostingController(rootView: homeView)
        hosting.title = "Home"
        navigationController.setViewControllers([hosting], animated: true)
    }
}
