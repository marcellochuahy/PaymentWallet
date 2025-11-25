//
//  UserDefaultsAuthTokenStoreTests.swift
//  PaymentWalletTests
//
//  Created by Marcello Chuahy on 25/11/25.
//

import XCTest
@testable import PaymentWallet

final class UserDefaultsAuthTokenStoreTests: XCTestCase {

    // MARK: - Properties

    private var sut: UserDefaultsAuthTokenStore!

    // MARK: - Lifecycle

    override func setUp() {
        super.setUp()
        sut = UserDefaultsAuthTokenStore()
        UserDefaults.standard.removeObject(forKey: "auth_token")
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "auth_token")
        sut = nil
        super.tearDown()
    }

    // MARK: - Tests

    func test_givenToken_whenSave_thenRetrieveSameToken() {
        // given
        let token = "abc123"

        // when
        sut.save(token: token)

        // then
        XCTAssertEqual(sut.get(), token)
    }

    func test_givenNoToken_whenGet_thenReturnsNil() {
        XCTAssertNil(sut.get())
    }

    func test_givenExistingToken_whenClear_thenGetReturnsNil() {
        // given
        sut.save(token: "abc123")

        // when
        sut.clear()

        // then
        XCTAssertNil(sut.get())
    }
}
