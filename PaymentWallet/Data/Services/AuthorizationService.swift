//
//  AuthorizationService.swift
//  PaymentWallet
//
//  Created by Marcello Chuahy on 25/11/25.
//

import Foundation

// MARK: - AuthorizationService

/// Service responsible for simulating a transfer authorization backend call.
protocol AuthorizationService {
    /// Simulates a POST /authorize call.
    ///
    /// - Parameter amount: transfer amount
    /// - Returns: `AuthorizationResult`
    ///
    /// Business Rule:
    /// - If amount == 403 → return authorized: false
    /// - Otherwise → return authorized: true
    func authorize(amount: Decimal) async -> AuthorizationResult
}
