//
//  AnalyticsService.swift
//  PaymentWallet
//
//  Created by Marcello Chuahy on 28/11/25.
//

import Foundation

// MARK: - AnalyticsService

/// Very lightweight analytics abstraction.
/// This is just a "placeholder" to give a sense that real apps send events.
protocol AnalyticsService {
    func logEvent(_ name: String, parameters: [String: String])
}
