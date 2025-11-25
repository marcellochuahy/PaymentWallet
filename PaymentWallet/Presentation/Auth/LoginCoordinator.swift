//
//  LoginCoordinator.swift
//  PaymentWallet
//
//  Created by Marcello Chuahy on 25/11/25.
//

import UIKit
import SwiftUI
import AuthFeature

// MARK: - LoginCoordinator

final class LoginCoordinator {

    // MARK: - Properties

    private let navigationController: UINavigationController
    private let dependencies: AppDependencies

    // MARK: - Initializers

    init(
        navigationController: UINavigationController,
        dependencies: AppDependencies
    ) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }

    // MARK: - Public Methods

    func start() {
        let loginView = AuthFeature.makeLoginView(
            performLogin: { [weak self] email, password in
                guard let self else { return false }
                return await self.performLogin(email: email, password: password)
            },
            onLoginSuccess: { [weak self] in
                self?.handleLoginSuccess()
            }
        )

        let hosting = UIHostingController(rootView: loginView)
        hosting.title = "Login"

        navigationController.setViewControllers([hosting], animated: false)
    }

    // MARK: - Private Methods

    @MainActor
    private func performLogin(email: String, password: String) async -> Bool {
        do {
            _ = try dependencies.authRepository.login(email: email, password: password)
            dependencies.authTokenStore.save(token: UUID().uuidString)
            return true
        } catch {
            return false
        }
    }

    private func handleLoginSuccess() {
        // TODO: later we'll navigate to HomeCoordinator here.
        let vc = UIViewController()
        vc.view.backgroundColor = .systemGreen
        vc.title = "Logged!"
        navigationController.pushViewController(vc, animated: true)
    }
}
