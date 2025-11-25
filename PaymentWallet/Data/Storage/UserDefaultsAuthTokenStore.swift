//
//  UserDefaultsAuthTokenStore.swift
//  PaymentWallet
//
//  Created by Marcello Chuahy on 25/11/25.
//

import Foundation

// MARK: - UserDefaultsAuthTokenStore

final class UserDefaultsAuthTokenStore: AuthTokenStore {

    // MARK: - Properties

    private let key = "auth_token"

    // MARK: - Methods

    func save(token: String) {
        UserDefaults.standard.set(token, forKey: key)
    }

    func get() -> String? {
        UserDefaults.standard.string(forKey: key)
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
