//
//  HomeViewModelTests.swift
//  WalletFeatureSampleAppTests
//
//  Created by Marcello Chuahy on 26/11/25.
//

import XCTest
@testable import WalletFeatureSampleApp

@MainActor
final class HomeViewModelTests: XCTestCase {

    // MARK: - Helpers
    
    private let defaultUserName = "Wolfgang Amadeus Mozart"
    private let defaultEmail = "user@example.com"

    private func makeSUT(
        userName: String = "Wolfgang Amadeus Mozart",
        email: String = "user@example.com",
        balance: Decimal = 1234.56,
        contacts: [WalletFeatureEntryPoint.Contact] = [
            .init(name: "Ludwig van Beethoven"),
            .init(name: "Clara Schumann"),
            .init(name: "Hildegard von Bingen")
        ],
        onSelect: @escaping (WalletFeatureEntryPoint.Contact) -> Void = { _ in }
    ) -> HomeViewModel {
        let user = WalletFeatureEntryPoint.UserInfo(name: userName, email: email)
        return HomeViewModel(
            user: user,
            loadBalance: { balance },
            loadContacts: { contacts },
            onSelectContact: onSelect
        )
    }

    private final class SelectContactSpy {
        
        private(set) var received: WalletFeatureEntryPoint.Contact?

        func handle(contact: WalletFeatureEntryPoint.Contact) {
            received = contact
        }
    }

    // MARK: - Tests

    func test_init_setsUserNameAndEmailFromUserInfo() {
        // GIVEN
        let expectedName = "Wolfgang Amadeus Mozart"
        let expectedEmail = "user@example.com"

        // WHEN
        let sut = makeSUT(
            userName: expectedName,
            email: expectedEmail
        )

        // THEN
        XCTAssertEqual(sut.userName, expectedName)
        XCTAssertEqual(sut.userEmail, expectedEmail)
    }

    func test_loadData_updatesBalanceTextAndContacts() {
        // GIVEN
        let contacts: [WalletFeatureEntryPoint.Contact] = [
            .init(name: "Ludwig van Beethoven"),
            .init(name: "Clara Schumann"),
            .init(name: "Hildegard von Bingen")
        ]

        let sut = makeSUT(
            balance: 999.99,
            contacts: contacts
        )

        // pré-condições
        XCTAssertEqual(sut.balanceText, "R$ 0,00")
        XCTAssertTrue(sut.contacts.isEmpty)

        // WHEN
        sut.loadData()

        // THEN – não ficamos presos em um formato exato de moeda
        XCTAssertFalse(sut.balanceText.isEmpty)
        XCTAssertNotEqual(sut.balanceText, "R$ 0,00")
        XCTAssertTrue(sut.balanceText.hasPrefix("R$"))

        XCTAssertEqual(sut.contacts.count, 3)
        XCTAssertEqual(sut.contacts.map(\.name), ["Ludwig van Beethoven", "Clara Schumann", "Hildegard von Bingen"])
    }

    func test_didTapContact_callsOnSelectContactWithCorrectContact() {
        // GIVEN
        let contacts: [WalletFeatureEntryPoint.Contact] = [
            .init(name: "Ludwig van Beethoven"),
            .init(name: "Clara Schumann"),
            .init(name: "Hildegard von Bingen")
        ]

        let spy = SelectContactSpy()

        let sut = makeSUT(
            contacts: contacts,
            onSelect: spy.handle(contact:)
        )

        let expectedContact = contacts[1] // Clara Schumann

        // WHEN
        sut.didTap(contact: expectedContact)

        // THEN
        XCTAssertEqual(spy.received?.id, expectedContact.id)
        XCTAssertEqual(spy.received?.name, expectedContact.name)
    }
    
    func test_didTapContact_forwardsContactToOnSelectContact() {
            // GIVEN
            let expectedContact = WalletFeatureEntryPoint.Contact(
                name: "Ludwig van Beethoven"
            )

            var receivedContact: WalletFeatureEntryPoint.Contact?

            let sut = makeSUT(
                contacts: [expectedContact],
                onSelect: { contact in
                    receivedContact = contact
                }
            )

            // WHEN
            sut.didTap(contact: expectedContact)

            // THEN
            XCTAssertEqual(receivedContact?.id, expectedContact.id)
            XCTAssertEqual(receivedContact?.name, expectedContact.name)
        }
    
}
