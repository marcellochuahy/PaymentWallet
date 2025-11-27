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
        let email = "ludwig@example.com"
        let accountDescription = "Conta corrente: R$ 1.804,37"
        
        // When
        let contact = WalletFeatureEntryPoint.Contact(name: name, email: email, accountDescription: accountDescription)
        let uuidString = contact.id.uuidString
        
        // Then
        XCTAssertEqual(contact.name, name)
        XCTAssertFalse(uuidString.isEmpty)
    }

    func testContactInitializationWithCustomIdUsesProvidedId() {
        // Given
        let customId = UUID()
        let name = "Clara Schumann"
        let email = "clara@example.com"
        let accountDescription = "Poupança: R$ 1.841,56"

        // When
        let contact = WalletFeatureEntryPoint.Contact(id: customId, name: name, email: email, accountDescription: accountDescription)

        // Then
        XCTAssertEqual(contact.id, customId)
        XCTAssertEqual(contact.name, name)
    }

    // MARK: - makeHomeView

    @MainActor
    func testMakeHomeView_CreatesAViewWithoutCrashing() {
        // Given
        let user = WalletFeatureEntryPoint.UserInfo(name: "Wolfgang Amadeus Mozart", email: "user@example.com")
        let contacts: [WalletFeatureEntryPoint.Contact] = [
            .init(name: "Ludwig van Beethoven", email: "ludwig@example.com", accountDescription: "Conta corrente: R$ 1.804,37"),
            .init(name: "Clara Schumann", email: "clara@example.com", accountDescription: "Poupança: R$ 1.841,56"),
            .init(name: "Hildegard von Bingen", email: "hildegard@example.com", accountDescription: "Conta do mosteiro: R$ 1.151,49")
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
