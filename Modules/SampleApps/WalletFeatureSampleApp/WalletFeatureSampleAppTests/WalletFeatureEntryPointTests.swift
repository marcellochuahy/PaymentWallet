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
        let userInfo = WalletFeatureEntryPoint.UserInfo(name: name, email: email)

        // Then
        XCTAssertEqual(userInfo.name, name)
        XCTAssertEqual(userInfo.email, email)
    }

    // MARK: - Contact

    func testContactInitializationWithDefaultIdGeneratesAnId() {
        // Given
        let name = "Ludwig van Beethoven"
        
        // When
        let contact = WalletFeatureEntryPoint.Contact(name: name)
        let uuidString = contact.id.uuidString
        
        // Then
        XCTAssertEqual(contact.name, name)
        XCTAssertFalse(uuidString.isEmpty)
    }

    func testContactInitializationWithCustomIdUsesProvidedId() {
        // Given
        let customId = UUID()
        let name = "Clara Schumann"

        // When
        let contact = WalletFeatureEntryPoint.Contact(id: customId, name: name)

        // Then
        XCTAssertEqual(contact.id, customId)
        XCTAssertEqual(contact.name, name)
    }

    // MARK: - makeHomeView

    @MainActor
    func testMakeHomeView_CreatesAViewWithoutCrashing() {
        // Given
        let user = WalletFeatureEntryPoint.UserInfo(name: "Wolfgang Amadeus Mozart", email: "user@example.com")
        let contacts = [
            WalletFeatureEntryPoint.Contact(name: "Ludwig van Beethoven"),
            WalletFeatureEntryPoint.Contact(name: "Clara Schumann"),
            WalletFeatureEntryPoint.Contact(name: "Hildegard von Bingen")
        ]

        // When
        let view = WalletFeatureEntryPoint.makeHomeView(
            user: user,
            loadBalance: { 1234.56 },
            loadContacts: { contacts },
            onSelectContact: { _ in }
        )

        let erased = AnyView(view)
        
        // Then
        XCTAssertNotNil(erased)
    }
}
