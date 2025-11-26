//
//  MockAuthRepository.swift
//  PaymentWallet
//
//  Created by Marcello Chuahy on 25/11/25.
//

import Foundation
import AuthFeature

final class MockAuthRepository: AuthRepository {

    private let validEmail = "user@example.com"
    private let validPassword = "123456"

    func login(email: String, password: String) throws -> User {
        
        let cleanedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let cleanedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanedEmail.isEmpty, !cleanedPassword.isEmpty else {
            throw AuthError.missingCredentials
        }

        if cleanedEmail == validEmail && cleanedPassword == validPassword {
            return User(name: "Wolfgang Amadeus Mozart", email: cleanedEmail)
        }

        throw AuthError.invalidCredentials
    }
}
