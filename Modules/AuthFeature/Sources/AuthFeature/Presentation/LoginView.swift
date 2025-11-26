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

            Text("Login")
                .font(.largeTitle.bold())

            TextField("E-mail", text: $viewModel.email)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)

            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(.roundedBorder)
                .textContentType(.password)

            if viewModel.isLoading {
                ProgressView()
            }

            Button("Enter") {
                Task {
                    await viewModel.login(onSuccess: onLoginSuccess)
                }
            }
            .buttonStyle(.borderedProminent)
            .padding(.top)

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
