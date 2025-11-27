//
//  LocalNotificationScheduler.swift
//  PaymentWallet
//
//  Created by Marcello Chuahy on 25/11/25.
//

import Foundation

// MARK: - LocalNotificationScheduler

/// Abstraction for scheduling local notifications in the app.
protocol LocalNotificationScheduler {
    /// Schedules a notification to inform the user about a successful transfer.
    func scheduleSuccessNotification(for amount: Decimal)

    /// Schedules a reminder when a transfer was not authorized.
    func scheduleAuthorizationReminder()
}
