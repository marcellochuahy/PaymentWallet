//
//  MockAuthRepository.swift
//  PaymentWallet
//
//  Created by Marcello Chuahy on 25/11/25.
//

import Foundation
import AuthFeature

final class MockAuthRepository: AuthRepository {

    let validEmail = "user@example.com"
    let validPassword = "123456"

    func login(email: String, password: String) throws -> (user: User, token: String) {

        let cleanedEmail = email
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        let cleanedPassword = password
            .trimmingCharacters(in: .whitespacesAndNewlines)

        // Validate mandatory fields
        guard !cleanedEmail.isEmpty, !cleanedPassword.isEmpty else {
            throw AuthError.missingCredentials
        }

        // Validate hardcoded credentials
        guard cleanedEmail == validEmail, cleanedPassword == validPassword else {
            throw AuthError.invalidCredentials
        }

        // Build authenticated user
        let user = User(
            name: "Wolfgang Amadeus Mozart",
            email: cleanedEmail
        )

        // Generate a fresh auth token (mock implementation)
        let token = UUID().uuidString

        return (user: user, token: token)
    }
}
