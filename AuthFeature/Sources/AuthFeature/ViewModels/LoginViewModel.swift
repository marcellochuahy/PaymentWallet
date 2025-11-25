//
//  LoginViewModel.swift
//  AuthFeature
//
//  Created by Marcello Chuahy on 25/11/25.
//

import Foundation
import Combine

// MARK: - LoginViewModel

/// Simple ViewModel that holds login form state and delegates the actual
/// authentication to an injected closure.
public final class LoginViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published public var email: String = ""
    @Published public var password: String = ""
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?

    // MARK: - Dependencies

    /// Closure responsible for performing login.
    /// It returns `true` on success, `false` on invalid credentials.
    private let performLogin: (String, String) async -> Bool

    // MARK: - Initializers

    public init(
        performLogin: @escaping (String, String) async -> Bool
    ) {
        self.performLogin = performLogin
    }

    // MARK: - Public Methods

    @MainActor
    public func login(onSuccess: @escaping () -> Void) async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }

        isLoading = true
        errorMessage = nil

        let success = await performLogin(email, password)

        isLoading = false

        if success {
            onSuccess()
        } else {
            errorMessage = "Invalid credentials."
        }
    }
}
