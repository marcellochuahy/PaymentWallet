//
//  AuthFeature.swift
//  AuthFeature
//
//  Created by Marcello Chuahy on 25/11/25.
//

import SwiftUI

// MARK: - AuthFeature

/// Factory methods for building AuthFeature views.
public enum AuthFeature {

    /// Creates a LoginView already wired with a LoginViewModel.
    ///
    /// - Parameters:
    ///   - performLogin: closure responsible for authenticating the user.
    ///   - onLoginSuccess: closure called when login succeeds.
    @MainActor
    public static func makeLoginView(
        performLogin: @escaping (String, String) async -> Bool,
        onLoginSuccess: @escaping () -> Void
    ) -> some View {
        let viewModel = LoginViewModel(performLogin: performLogin)
        return LoginView(
            viewModel: viewModel,
            onLoginSuccess: onLoginSuccess
        )
    }
}
