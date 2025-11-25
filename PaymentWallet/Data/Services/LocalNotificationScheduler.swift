//
//  LocalNotificationScheduler.swift
//  PaymentWallet
//
//  Created by Marcello Chuahy on 25/11/25.
//

import Foundation

// MARK: - LocalNotificationScheduler

/// Schedules simple local notifications.
/// This is used after a successful transfer.
protocol LocalNotificationScheduler {
    func scheduleSuccessNotification(for amount: Decimal)
}
