//
//  LocalNotificationSchedulerImpl.swift
//  PaymentWallet
//
//  Created by Marcello Chuahy on 25/11/25.
//

import Foundation
import UserNotifications

// MARK: - LocalNotificationSchedulerImpl

/// Concrete implementation of LocalNotificationScheduler using UNUserNotificationCenter.
/// It requests authorization on demand and schedules a simple success notification after a transfer.
final class LocalNotificationSchedulerImpl: LocalNotificationScheduler {

    // MARK: - Methods

    func scheduleSuccessNotification(for amount: Decimal) {
        let notificationCenter = UNUserNotificationCenter.current()

        notificationCenter.getNotificationSettings { [weak self] settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                self?.requestAuthorizationAndScheduleIfGranted(
                    center: notificationCenter,
                    amount: amount
                )
            case .authorized, .provisional:
                self?.scheduleNotification(
                    center: notificationCenter,
                    amount: amount
                )
            case .denied, .ephemeral:
                // For this challenge, we simply do nothing if notifications are denied.
                break
            @unknown default:
                break
            }
        }
    }

    // MARK: - Private Methods

    private func requestAuthorizationAndScheduleIfGranted(
        center: UNUserNotificationCenter,
        amount: Decimal
    ) {
        center.requestAuthorization(options: [.alert, .sound]) { [weak self] granted, _ in
            guard granted else { return }
            self?.scheduleNotification(center: center, amount: amount)
        }
    }

    private func scheduleNotification(
        center: UNUserNotificationCenter,
        amount: Decimal
    ) {
        let content = UNMutableNotificationContent()
        content.title = "Transfer completed"
        content.body = "Your transfer of \(formatCurrency(amount)) was authorized successfully."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        center.add(request, withCompletionHandler: nil)
    }

    private func formatCurrency(_ amount: Decimal) -> String {
        let number = amount as NSDecimalNumber
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        // Using pt_BR to match the Brazilian real format (R$).
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: number) ?? "\(amount)"
    }
}
