//
//  TestDependenciesContainer.swift
//  PaymentWalletTests
//
//  Created by Marcello Chuahy on 27/11/25.
//

import Foundation
@testable import PaymentWallet

final class TestDependenciesContainer: AppDependencies {
    
    

    // MARK: - Stored Dependencies (fully injectable)

    var authRepository: AuthRepository
    var walletRepository: WalletRepository
    var authTokenStore: AuthTokenStore
    var authorizationService: AuthorizationService
    var notificationScheduler: LocalNotificationScheduler
    var analytics:  AnalyticsService

    // MARK: - Initializers

    init(
        authRepository: AuthRepository,
        walletRepository: WalletRepository,
        authTokenStore: AuthTokenStore,
        authorizationService: AuthorizationService,
        notificationScheduler: LocalNotificationScheduler,
        analytics:  AnalyticsService
    ) {
        self.authRepository = authRepository
        self.walletRepository = walletRepository
        self.authTokenStore = authTokenStore
        self.authorizationService = authorizationService
        self.notificationScheduler = notificationScheduler
        self.analytics =  analytics
    }
}
