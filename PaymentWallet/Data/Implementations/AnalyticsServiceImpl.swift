//
//  AnalyticsServiceImpl.swift
//  PaymentWallet
//
//  Created by Marcello Chuahy on 28/11/25.
//

import Foundation

/// Console-based implementation used in this challenge.
final class AnalyticsServiceImpl: AnalyticsService {
    func logEvent(_ name: String, parameters: [String: String]) {
        print("📊 [Analytics] Event: \(name) | Params: \(parameters)")
    }
}
