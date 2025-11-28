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
class AuthCoordinator {

    // MARK: - Properties

    /// Navigation controller used to present screens in the authentication flow.
    let navigationController: UINavigationController

    /// High-level dependency provider (repositories, analytics, services, storage).
    private let dependencies: AppDependencies

    /// Retains the HomeCoordinator to keep it alive after login.
    private var homeCoordinator: HomeCoordinator?

    // MARK: - Initializer

    init(navigationController: UINavigationController, dependencies: AppDependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }

    // MARK: - Start Flow

    /// Entry point for the authentication flow.
    /// Checks if an auth token already exists and decides whether to show Login or jump to Home.
    func start() {

        // AUTO-LOGIN BEHAVIOR
        if let existingToken = dependencies.authTokenStore.get(),
           !existingToken.isEmpty {

            // Optional analytics instrumentation
            dependencies.analytics.logEvent(
                "auto_login_used",
                parameters: [
                    "timestamp": ISO8601DateFormatter().string(from: Date()),
                    "token": existingToken
                ]
            )

            // Skip login and go directly to the Home flow.
            handleLoginSuccess()
            return
        }

        // Normal login flow: show the Login screen.
        let loginVC = makeLoginViewController()
        navigationController.setViewControllers([loginVC], animated: false)
    }

    // MARK: - Factory (Test Override Point)

    /// Creates the Login screen view controller.
    /// In production this wraps the SwiftUI view inside a `UIHostingController`.
    ///
    /// Tests override this method to avoid instantiating SwiftUI/UIKit internals.
    func makeLoginViewController() -> UIViewController {
        let loginView = AuthFeatureEntryPoint.makeLoginView(
            performLogin: { [weak self] email, password in
                guard let self else { throw AuthError.unknown }
                try await self.performLogin(email: email, password: password)
            },
            onLoginSuccess: { [weak self] in
                self?.handleLoginSuccess()
            }
        )

        let hosting = UIHostingController(rootView: loginView)
        hosting.title = "Login"
        return hosting
    }

    // MARK: - Login Logic

    /// Handles the login operation — delegates to the AuthRepository, persists the token,
    /// and performs optional analytics instrumentation.
    func performLogin(email: String, password: String) async throws {

        do {
            // AuthRepository returns (user, token)
            let result = try dependencies.authRepository.login(email: email, password: password)

            // Persist received token
            dependencies.authTokenStore.save(token: result.token)

            // Optional analytics instrumentation
            dependencies.analytics.logEvent(
                "token_generated",
                parameters: [
                    "timestamp": ISO8601DateFormatter().string(from: Date()),
                    "token": result.token
                ]
            )
            
            _ = result.user // Reserved for future use (navigation, personalization, etc.)
        }
        catch let error as AuthError {
            throw error // Propagate domain error
        }
        catch {
            throw AuthError.unknown // Map unexpected errors to a domain error
        }
    }

    // MARK: - Navigation after Login

    /// Called when login succeeds (manual or auto-login).
    /// Records analytics, initializes the HomeCoordinator, and starts the Home flow.
    func handleLoginSuccess() {

        let token = dependencies.authTokenStore.get() ?? "unknown"

        dependencies.analytics.logEvent(
            "login_success",
            parameters: [
                "timestamp": ISO8601DateFormatter().string(from: Date()),
                "token": token
            ]
        )

        let homeCoord = HomeCoordinator(
            navigationController: navigationController,
            dependencies: dependencies
        )

        self.homeCoordinator = homeCoord // Retain child coordinator
        homeCoord.start()
    }
}
