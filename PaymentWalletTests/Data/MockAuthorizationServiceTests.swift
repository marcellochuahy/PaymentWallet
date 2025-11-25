//
//  MockAuthorizationServiceTests.swift
//  PaymentWalletTests
//
//  Created by Marcello Chuahy on 25/11/25.
//

import XCTest
@testable import PaymentWallet

final class MockAuthorizationServiceTests: XCTestCase {

    // MARK: - Properties

    private var sut: MockAuthorizationService!

    // MARK: - Lifecycle

    override func setUp() {
        super.setUp()
        sut = MockAuthorizationService()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Tests

    @MainActor
    func test_givenNormalAmount_whenAuthorize_thenReturnsAuthorizedTrue() async {
        // given
        let amount: Decimal = 100

        // when
        let result = await sut.authorize(amount: amount)

        // then
        XCTAssertTrue(result.isAuthorized)
        XCTAssertNil(result.reason)
    }

    @MainActor
    func test_given403Amount_whenAuthorize_thenReturnsAuthorizedFalse() async {
        // given
        let amount: Decimal = 403

        // when
        let result = await sut.authorize(amount: amount)

        // then
        XCTAssertFalse(result.isAuthorized)
        XCTAssertEqual(result.reason, "operation not allowed")
    }
}
