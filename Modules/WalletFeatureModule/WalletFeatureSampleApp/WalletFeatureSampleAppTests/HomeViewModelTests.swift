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

    private func makeSUT(
        userName: String = "Wolfgang Amadeus Mozart",
        email: String = "user@example.com",
        balance: Decimal = 1234.56,
        contacts: [WalletFeatureEntryPoint.Contact] = [
            .init(
                name: "Ludwig van Beethoven",
                email: "ludwig@example.com",
                accountDescription: "Conta corrente: R$ 1.804,37"
            ),
            .init(
                name: "Clara Schumann",
                email: "clara@example.com",
                accountDescription: "Poupança: R$ 1.841,56"
            ),
            .init(
                name: "Hildegard von Bingen",
                email: "hildegard@example.com",
                accountDescription: "Conta do mosteiro: R$ 1.151,49"
            )
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
            .init(
                name: "Ludwig van Beethoven",
                email: "ludwig@example.com",
                accountDescription: "Conta corrente: R$ 1.804,37"
            ),
            .init(
                name: "Clara Schumann",
                email: "clara@example.com",
                accountDescription: "Poupança: R$ 1.841,56"
            ),
            .init(
                name: "Hildegard von Bingen",
                email: "hildegard@example.com",
                accountDescription: "Conta do mosteiro: R$ 1.151,49"
            )
        ]

        let sut = makeSUT(
            balance: 999.99,
            contacts: contacts
        )

        // Pre-conditions
        XCTAssertEqual(sut.balanceText, "R$ 0,00")
        XCTAssertTrue(sut.contacts.isEmpty)

        // WHEN
        sut.loadData()

        // THEN – we do not depend on an exact currency string here
        XCTAssertFalse(sut.balanceText.isEmpty)
        XCTAssertNotEqual(sut.balanceText, "R$ 0,00")
        XCTAssertTrue(sut.balanceText.hasPrefix("R$"))

        XCTAssertEqual(sut.contacts.count, 3)
        XCTAssertEqual(
            sut.contacts.map(\.name),
            ["Ludwig van Beethoven", "Clara Schumann", "Hildegard von Bingen"]
        )
    }

    func test_loadData_formatsBalanceUsingPtBRLocale() {
        // GIVEN
        let sut = makeSUT(
            balance: 350,
            contacts: []
        )

        // Pre-condition
        XCTAssertEqual(sut.balanceText, "R$ 0,00")

        // WHEN
        sut.loadData()

        // THEN
        
        let expected = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = Locale(identifier: "pt_BR")
            return formatter.string(from: 350 as NSNumber)!
        }()
        
        XCTAssertEqual(
            sut.balanceText,
            expected,
            "Balance text should be formatted using pt_BR currency style."
        )
    }

    func test_didTapContact_forwardsContactToOnSelectContact() {
        // GIVEN
        let contacts: [WalletFeatureEntryPoint.Contact] = [
            .init(
                name: "Ludwig van Beethoven",
                email: "ludwig@example.com",
                accountDescription: "Conta corrente: R$ 1.804,37"
            ),
            .init(
                name: "Clara Schumann",
                email: "clara@example.com",
                accountDescription: "Poupança: R$ 1.841,56"
            ),
            .init(
                name: "Hildegard von Bingen",
                email: "hildegard@example.com",
                accountDescription: "Conta do mosteiro: R$ 1.151,49"
            )
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
        XCTAssertEqual(spy.received?.email, expectedContact.email)
        XCTAssertEqual(spy.received?.accountDescription, expectedContact.accountDescription)
    }
 
}
