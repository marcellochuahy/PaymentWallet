//
//  AuthRepository.swift
//  PaymentWallet
//
//  Created by Marcello Chuahy on 25/11/25.
//

import Foundation

// MARK: - AuthRepository

/// Repository responsible for handling user authentication.
/// In this challenge, all implementations will be local and in-memory.
protocol AuthRepository {
    /// Attempts to authenticate a user using hardcoded credentials.
    /// Returns the authenticated user and a freshly generated auth token if the credentials are valid.
    func login(email: String, password: String) throws -> (user: User, token: String)
}
