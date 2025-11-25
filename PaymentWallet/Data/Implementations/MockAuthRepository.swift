//
//  MockAuthRepository.swift
//  PaymentWallet
//
//  Created by Marcello Chuahy on 25/11/25.
//

import Foundation

// MARK: - MockAuthRepository

final class MockAuthRepository: AuthRepository {

    // MARK: - Properties

    private let validEmail = "user@example.com"
    private let validPassword = "123456"

    // MARK: - Methods

    func login(email: String, password: String) throws -> User {
        if email == validEmail && password == validPassword {
            return User(name: "John Doe", email: email)
        }
        throw NSError(domain: "AuthError", code: 1, userInfo: nil)
    }
}
