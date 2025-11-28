//
//  AuthRepositoryTests.swift
//  PaymentWalletTests
//
//  Created by Marcello Chuahy on 27/11/25.
//

import XCTest
import AuthFeature

@testable import PaymentWallet

@MainActor
final class AuthRepositoryTests: XCTestCase {
    
    // MARK: - SUT
    
    var sut: AuthRepository!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        sut = MockAuthRepository()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    // ✅ Requirement 1.1.

    func test_login_withValidCredentials_returnsUserAndToken() {
        // WHEN
        let email = "user@example.com"
        let password = "123456"
        // THEN
        XCTAssertNoThrow(try {
            let result = try sut.login(email: email, password: password)
            let user = result.user
            let token = result.token
            XCTAssertEqual(user.name, "Wolfgang Amadeus Mozart")
            XCTAssertEqual(user.email, "user@example.com")
            XCTAssertTrue(token.isNotEmpty)
        }())
    }
    
    func test_login_withWrongEmail_throwsInvalidCredentials() {
        // WHEN
        let email = "wrong@example.com"
        let password = "123456"
        // THEN
        XCTAssertThrowsError(try sut.login(email: email, password: password)) { error in
            XCTAssertEqual(error as? AuthError, .invalidCredentials)
        }
    }
    
    func test_login_withWrongPassword_throwsInvalidCredentials() {
        // WHEN
        let email = "user@example.com"
        let password = "000000"
        // THEN
        XCTAssertThrowsError(try sut.login(email: email, password: password)) { error in
            XCTAssertEqual(error as? AuthError, .invalidCredentials)
        }
    }
    
    func test_login_withEmptyEmail_throwsMissingCredentials() {
        // WHEN
        let email = ""
        let password = "000000"
        // THEN
        XCTAssertThrowsError(try sut.login(email: email, password: password)) { error in
            XCTAssertEqual(error as? AuthError, .missingCredentials)
        }
    }
    
    func test_login_withEmptyPassword_throwsMissingCredentials() {
        // WHEN
        let email = "user@example.com"
        let password = ""
        // THEN
        XCTAssertThrowsError(try sut.login(email: email, password: password)) { error in
            XCTAssertEqual(error as? AuthError, .missingCredentials)
        }
    }
    
    func test_login_trimsWhitespaceFromCredentials() {
        // WHEN
        let email = "   user@example.com   "
        let password = "   123456   "
        // THEN
        XCTAssertNoThrow(try {
            let result = try sut.login(email: email, password: password)
            let user = result.user
            let token = result.token
            XCTAssertEqual(user.name, "Wolfgang Amadeus Mozart")
            XCTAssertEqual(user.email, "user@example.com")
            XCTAssertTrue(token.isNotEmpty)
        }())
    }

}

