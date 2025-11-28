//
//  AppDependencies.swift
//  PaymentWallet
//
//  Created by Marcello Chuahy on 25/11/25.
//

import Foundation

// MARK: - AppDependencies

/// High-level dependency container abstraction.
/// It exposes all core services and repositories that the presentation layer can depend on.
/// Concrete implementations can be used in production and tests.
protocol AppDependencies {
    
    // Repositories
    var authRepository: AuthRepository { get }
    var walletRepository: WalletRepository { get }

    // Storage
    var authTokenStore: AuthTokenStore { get }

    // Services
    var authorizationService: AuthorizationService { get }
    var notificationScheduler: LocalNotificationScheduler { get }

    // Analytics
    var analytics: AnalyticsService { get }
}

// MARK: - DependencyContainer

/// Default implementation of AppDependencies for the application.
/// This container wires all concrete implementations together.
/// In this challenge, everything is mocked or local.
final class DependencyContainer: AppDependencies {

    // MARK: - Repositories

    lazy var authRepository: AuthRepository = {
        MockAuthRepository()
    }()

    lazy var walletRepository: WalletRepository = {
        MockWalletRepository()
    }()

    // MARK: - Storage

    lazy var authTokenStore: AuthTokenStore = {
        UserDefaultsAuthTokenStore()
    }()

    // MARK: - Services

    lazy var authorizationService: AuthorizationService = {
        MockAuthorizationService()
    }()

    lazy var notificationScheduler: LocalNotificationScheduler = {
        LocalNotificationSchedulerImpl()
    }()

    // MARK: - Analytics

    lazy var analytics: AnalyticsService = {
        AnalyticsServiceImpl()
    }()

    // MARK: - Initializers

    init() { }
}
