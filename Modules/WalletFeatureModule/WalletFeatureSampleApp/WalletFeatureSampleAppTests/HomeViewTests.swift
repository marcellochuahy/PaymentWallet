//
//  HomeViewTests.swift
//  WalletFeatureSampleAppTests
//
//  Created by Marcello Chuahy on 26/11/25.
//

import XCTest
import ViewInspector
@testable import WalletFeatureSampleApp

@MainActor
final class HomeViewTests: XCTestCase {

    // MARK: - Helpers

    private func makeSUT(
        userName: String,
        email: String,
        balance: Decimal,
        contacts: [ContactDataTransfer],
        onSelectContact: @escaping (ContactDataTransfer) -> Void = { _ in }
    ) -> HomeView {
        let user = UserInfoDataTransfer(
            name: userName,
            email: email
        )

        let viewModel = HomeViewModel(
            user: user,
            loadBalance: { balance },
            loadContacts: { contacts },
            onSelectContact: onSelectContact
        )

        return HomeView(viewModel: viewModel)
    }

    // MARK: - Tests

    func testHomeView_showsUserSectionWithNameAndEmail() throws {
        // GIVEN
        let sut = makeSUT(userName: "Johann Sebastian Bach",
                          email: "johann@illbebach.com",
                          balance: Constants.balanceMock,
                          contacts: Constants.contactsMock)

        // WHEN – força o onAppear (carrega dados via viewModel.loadData)
        try sut.inspect().navigationView().callOnAppear()

        // THEN – primeira section é "User"
        let list = try sut.inspect().navigationView().list()
        let userSection = try list.section(0)

        let nameText = try userSection.text(0).string()
        let emailText = try userSection.text(1).string()

        XCTAssertEqual(nameText, "Johann Sebastian Bach")
        XCTAssertEqual(emailText, "johann@illbebach.com")
    }

    func testHomeView_showsContactsList() throws {
        // GIVEN
        let sut = makeSUT(userName: Constants.userMock.name,
                          email: Constants.userMock.email,
                          balance: Constants.balanceMock,
                          contacts: Constants.contactsMock)

        // WHEN
        try sut
            .inspect()
            .navigationView()
            .callOnAppear()

        // THEN – terceira section é "Contacts"
        let list = try sut
            .inspect()
            .navigationView()
            .list()
        
        let contactsSection = try list.section(2)
        
        let contactsForEach = try contactsSection.forEach(0)

        XCTAssertEqual(contactsForEach.count, 3)
        XCTAssertEqual(try contactsForEach.button(0).labelView().text().string(), "Ludwig van Beethoven")
        XCTAssertEqual(try contactsForEach.button(1).labelView().text().string(), "Clara Schumann")
        XCTAssertEqual(try contactsForEach.button(2).labelView().text().string(), "Hildegard von Bingen")
    }

    func testHomeView_tappingContact_callsOnSelectContact() throws {
        // GIVEN
        var tappedContact: ContactDataTransfer?
        let contact = Constants.contact1Mock
        let sut = makeSUT(userName: Constants.userMock.name,
                          email: Constants.userMock.email,
                          balance: Constants.balanceMock,
                          contacts: [contact],
                          onSelectContact: { tappedContact = $0 })
        try sut
            .inspect()
            .navigationView()
            .callOnAppear()

        // WHEN – toca no primeiro botão da lista de contatos
        let list = try sut.inspect().navigationView().list()
        let contactsSection = try list.section(2)
        try contactsSection.forEach(0).button(0).tap()

        // THEN
        XCTAssertEqual(tappedContact?.id, contact.id)
        XCTAssertEqual(tappedContact?.name, "Ludwig van Beethoven")
    }

    func testHomeView_showsEmptyStateWhenNoContacts() throws {
        // GIVEN
        let sut = makeSUT(userName: Constants.userMock.name,
                          email: Constants.userMock.email,
                          balance: Constants.balanceMock,
                          contacts: [])

        // WHEN – dispara o onAppear para carregar os dados
        try sut.inspect()
            .navigationView()
            .callOnAppear()

        // THEN – terceira section deve ser "Contacts"
        let list = try sut
                    .inspect()
                    .navigationView()
                    .list()

        let contactsSection = try list.section(2)

        // Dentro da seção, o primeiro filho é o Text do estado vazio
        let emptyStateText = try contactsSection
                                 .text(0)
                                 .string()

        XCTAssertEqual(emptyStateText, "No contacts available.")
    }
    
}
