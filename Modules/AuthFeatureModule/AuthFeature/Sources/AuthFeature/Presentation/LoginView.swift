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

// MARK: - Preview

#if DEBUG
// MARK: - Preview Helpers

/// A tiny mock that simulates login always succeeding.
private func previewPerformLoginSuccess(_: String, _: String) async throws {
    // Simula um pequeno delay para visualizar o loading no preview
    try? await Task.sleep(nanoseconds: 400_000_000)
}

/// Mock que sempre falha (útil se quiser criar outro preview)
private func previewPerformLoginFailure(_: String, _: String) async throws {
    throw AuthError.invalidCredentials
}

// MARK: - Previews

#Preview("Login – Light") {
    LoginView(
        viewModel: LoginViewModel(performLogin: previewPerformLoginSuccess),
        onLoginSuccess: {}
    )
}

#Preview("Login – Dark") {
    LoginView(
        viewModel: LoginViewModel(performLogin: previewPerformLoginSuccess),
        onLoginSuccess: {}
    )
    .preferredColorScheme(.dark)
}

#endif
