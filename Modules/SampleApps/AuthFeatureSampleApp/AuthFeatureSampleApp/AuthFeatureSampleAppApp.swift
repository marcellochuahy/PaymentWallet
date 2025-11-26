//
//  AuthFeatureSampleAppApp.swift
//  AuthFeatureSampleApp
//
//  Created by Marcello Chuahy on 26/11/25.
//

import SwiftUI
import AuthFeature

@main
struct AuthFeatureSampleAppApp: App {

    private let performLogin: (String, String) async throws -> Void = { email, password in
        try await Task.sleep(nanoseconds: 300_000_000)
        if email != "user@example.com" || password != "123456" {
            throw AuthError.invalidCredentials
        }
    }

    var body: some Scene {
        WindowGroup {
            AuthFeatureEntryPoint.makeLoginView(
                performLogin: performLogin,
                onLoginSuccess: {
                    print("✅ Login OK no sample app")
                }
            )
        }
    }
}
