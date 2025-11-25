//
//  AuthTokenStore.swift
//  PaymentWallet
//
//  Created by Marcello Chuahy on 25/11/25.
//

import Foundation

// MARK: - AuthTokenStore

/// A persistence abstraction for saving and retrieving the auth token.
/// Implementations are expected to use UserDefaults for this challenge.
protocol AuthTokenStore {
    func save(token: String)
    func get() -> String?
    func clear()
}
