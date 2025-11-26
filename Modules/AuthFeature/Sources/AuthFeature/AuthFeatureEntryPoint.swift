//
//  AuthFeature.swift
//  AuthFeature
//
//  Created by Marcello Chuahy on 25/11/25.
//

import SwiftUI

public enum AuthFeatureEntryPoint {

    @MainActor
    public static func makeLoginView(
        performLogin: @escaping (String, String) async throws -> Void,
        onLoginSuccess: @escaping () -> Void
    ) -> some View {
        let viewModel = LoginViewModel(performLogin: performLogin)
        return LoginView(viewModel: viewModel, onLoginSuccess: onLoginSuccess)
    }
}
