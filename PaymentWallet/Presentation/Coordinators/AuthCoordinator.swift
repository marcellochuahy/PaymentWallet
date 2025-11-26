//
//  AuthCoordinator.swift
//  PaymentWallet
//
//  Created by Marcello Chuahy on 25/11/25.
//

import UIKit
import SwiftUI
import AuthFeature

@MainActor
final class AuthCoordinator {

    // MARK: - Properties

    private let navigationController: UINavigationController
    private let dependencies: AppDependencies

    // MARK: - Initializer

    init(navigationController: UINavigationController, dependencies: AppDependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }

    // MARK: - Public Methods

    func start() {
        let loginView = AuthFeatureEntryPoint.makeLoginView(
            performLogin: { [weak self] email, password in
                guard let self else {
                    throw AuthError.unknown
                }
                try await self.performLogin(email: email, password: password)
            },
            onLoginSuccess: { [weak self] in
                self?.handleLoginSuccess()
            }
        )

        let hosting = UIHostingController(rootView: loginView)
        hosting.title = "Login"

        navigationController.setViewControllers([hosting], animated: false)
    }

    // MARK: - Login flow

    func performLogin(email: String, password: String) async throws {
        do {
            let user = try dependencies.authRepository.login(email: email, password: password)
            let token = UUID().uuidString
            dependencies.authTokenStore.save(token: token)

            // For now we don’t need the user instance here,
            // but we keep it for future navigation if needed.
            _ = user
        } catch let authError as AuthError {
            throw authError
        } catch {
            throw AuthError.unknown
        }
    }

    func handleLoginSuccess() {
        let homeCoordinator = HomeCoordinator(
            navigationController: navigationController,
            dependencies: dependencies
        )
        homeCoordinator.start()
    }
}
