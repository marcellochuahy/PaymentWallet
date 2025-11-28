//
//  SceneDelegate.swift
//  PaymentWallet
//
//  Created by Marcello Chuahy on 25/11/25.
//

import UIKit
import UserNotifications

class SceneDelegate: UIResponder, UIWindowSceneDelegate, UNUserNotificationCenterDelegate {

    // MARK: - Properties
    
    var window: UIWindow?
    private var dependencies: AppDependencies?
    private var coordinator: AuthCoordinator?

    // MARK: - Lifecycle
    
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        
        dependencies = DependencyContainer()
        
        guard
            let windowScene = (scene as? UIWindowScene),
            let dependencies = dependencies
        else { return }
        
        // ⚠️ Important: configure notification center delegate and request authorization
        configureNotifications()
        
        let window = UIWindow(windowScene: windowScene)
        let rootViewController = RootViewController(dependencies: dependencies)
        let navigationController = UINavigationController(rootViewController: rootViewController)
        
        window.rootViewController = navigationController
        window.overrideUserInterfaceStyle = .unspecified
        
        self.window = window
        window.makeKeyAndVisible()
        
        // Start and retain LoginCoordinator here to ensure its lifecycle is stable
        let coordinator = AuthCoordinator(
            navigationController: navigationController,
            dependencies: dependencies
        )
        self.coordinator = coordinator
        coordinator.start()
    }

    // MARK: - Notifications setup
    
    /// Configures UNUserNotificationCenter to allow banners while the app is in foreground.
    private func configureNotifications() {
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error {
                print("🔔 Notification authorization error: \(error)")
            } else {
                print("🔔 Notification authorization granted: \(granted)")
            }
        }
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    /// Called when a notification is delivered while the app is in foreground.
    /// By default, iOS does *not* show banner/sound in foreground; we explicitly opt-in here.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show banner + sound + keep in notification list even with app open
        completionHandler([.banner, .sound, .list])
    }
    
    /// Optional: handle taps on the notification.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        // For now we just finish. Here you could route the user to a specific screen.
        completionHandler()
    }

}
