//
//  AuthorizationResult.swift
//  PaymentWallet
//
//  Created by Marcello Chuahy on 25/11/25.
//

import Foundation

struct AuthorizationResult: Equatable {
    let isAuthorized: Bool
    let reason: String?

    init(isAuthorized: Bool, reason: String? = nil) {
        self.isAuthorized = isAuthorized
        self.reason = reason
    }
}
