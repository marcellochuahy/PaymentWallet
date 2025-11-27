//
//  WalletFeatureEntryPointTests.swift
//  WalletFeatureSampleAppTests
//
//  Created by Marcello Chuahy on 26/11/25.
//

import XCTest
import SwiftUI
@testable import WalletFeatureSampleApp

final class WalletFeatureEntryPointTests: XCTestCase {

    // MARK: - UserInfo

    func testUserInfoInitializationStoresNameAndEmail() {
        // Given
        let name = "Wolfgang Amadeus Mozart"
        let email = "user@example.com"

        // When
        let userInfo = UserInfoDataTransfer(name: name, email: email)

        // Then
        XCTAssertEqual(userInfo.name, name)
        XCTAssertEqual(userInfo.email, email)
    }

    // MARK: - makeHomeView

    @MainActor
    func testMakeHomeView_CreatesAViewWithoutCrashing() {

        let user = Constants.userMock
        
        // When
        let view = WalletFeatureEntryPoint.makeHomeView(
            user: Constants.userMock,
            loadBalance: { Constants.balanceMock },
            loadContacts: { Constants.contactsMock },
            onSelectContact: { _ in }
        )

        let erased = AnyView(view)
        
        // Then
        XCTAssertNotNil(erased)
    }
}
