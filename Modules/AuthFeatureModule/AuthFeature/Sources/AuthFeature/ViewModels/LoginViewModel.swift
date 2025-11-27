//
//  LoginViewModel.swift
//  AuthFeature
//
//  Created by Marcello Chuahy on 25/11/25.
//

import Foundation
import AuthFeature

@MainActor
public final class LoginViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published public var email: String = ""
    @Published public var password: String = ""
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?

    // MARK: - Dependencies

    /// Performs login and throws on failure.
    private let performLogin: (String, String) async throws -> Void

    // MARK: - Initializer

    public init(performLogin: @escaping (String, String) async throws -> Void) {
        self.performLogin = performLogin
    }

    // MARK: - Public Methods

    public func login(onSuccess: @escaping () -> Void) async {
        
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        // Validate empty fields
        guard !trimmedEmail.isEmpty, !trimmedPassword.isEmpty else {
            errorMessage = NSLocalizedString(
                "auth.error.emptyFields",
                comment: "Error shown when email or password is empty"
            )
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            try await performLogin(trimmedEmail, trimmedPassword)
            isLoading = false
            onSuccess()
        }
        catch let authError as AuthError {
            isLoading = false
            errorMessage = authError.errorDescription
        }
        catch {
            isLoading = false

            if (error as? URLError)?.code == .notConnectedToInternet {
                errorMessage = NSLocalizedString(
                    "auth.error.noInternet",
                    comment: "No internet connection error"
                )
            } else {
                errorMessage = NSLocalizedString(
                    "auth.error.unexpected",
                    comment: "Unexpected login failure"
                )
            }
        }
    }
}
