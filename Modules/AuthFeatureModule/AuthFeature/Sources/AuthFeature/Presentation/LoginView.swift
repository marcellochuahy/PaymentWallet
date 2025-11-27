//
//  LoginView.swift
//  AuthFeature
//
//  Created by Marcello Chuahy on 25/11/25.
//

import SwiftUI

// MARK: - LoginView

/// SwiftUI login screen.
/// Uses a LoginViewModel and callbacks for success.
@MainActor
public struct LoginView: View {

    // MARK: - Properties

    @StateObject private var viewModel: LoginViewModel
    private let onLoginSuccess: () -> Void

    // MARK: - Initializers

    public init(viewModel: LoginViewModel, onLoginSuccess: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onLoginSuccess = onLoginSuccess
    }

    // MARK: - View

    public var body: some View {
        VStack(spacing: 24) {

            // Title
            Text(NSLocalizedString("auth.title", comment: "Login title"))
                .font(.largeTitle.bold())

            // Email field
            TextField(
                NSLocalizedString("auth.emailPlaceholder", comment: "E-mail field placeholder"),
                text: $viewModel.email
            )
            .textFieldStyle(.roundedBorder)
            .keyboardType(.emailAddress)
            .textContentType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)

            // Password field
            SecureField(
                NSLocalizedString("auth.passwordPlaceholder", comment: "Password field placeholder"),
                text: $viewModel.password
            )
            .textFieldStyle(.roundedBorder)
            .textContentType(.password)

            // Loading indicator
            if viewModel.isLoading {
                ProgressView()
            }

            // Login button
            Button(NSLocalizedString("auth.enterButton", comment: "Login button")) {
                Task {
                    await viewModel.login(onSuccess: onLoginSuccess)
                }
            }
            .buttonStyle(.borderedProminent)
            .padding(.top)

            // Error label
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.callout)
            }

            Spacer()
        }
        .padding()
    }
}
