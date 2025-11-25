//
//  MockAuthorizationService.swift
//  PaymentWallet
//
//  Created by Marcello Chuahy on 25/11/25.
//

import Foundation

// MARK: - MockAuthorizationService

final class MockAuthorizationService: AuthorizationService {

    func authorize(amount: Decimal) async -> AuthorizationResult {
        if amount == 403 {
            return AuthorizationResult(
                isAuthorized: false,
                reason: "operation not allowed"
            )
        }

        return AuthorizationResult(isAuthorized: true)
    }
}
