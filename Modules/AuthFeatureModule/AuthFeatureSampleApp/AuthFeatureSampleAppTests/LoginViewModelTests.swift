//
//  LoginViewModel.swift
//  AuthFeatureEntryPoint
//
//  Created by Marcello Chuahy on 25/11/25.
//

import XCTest
@testable import AuthFeature

@MainActor
final class LoginViewModelTests: XCTestCase {
    
    enum AuthErrorKey {
        static let emptyFields        = "auth.error.emptyFields"
        static let invalidCredentials = "auth.error.invalidCredentials"
        static let noInternet         = "auth.error.noInternet"
        static let unexpected         = "auth.error.unexpected"
    }

    // MARK: - Tests

    func test_login_whenFieldsAreEmpty_doesNotCallPerformLogin_andSetsValidationError() async {
        // given
        var performLoginCalled = false

        let sut = LoginViewModel { _, _ in
            performLoginCalled = true
        }

        // email and password start empty by default
        var onSuccessCalled = false

        // when
        await sut.login {
            onSuccessCalled = true
        }

        // then
        XCTAssertEqual(sut.errorMessage, AuthErrorKey.emptyFields)
        XCTAssertFalse(sut.isLoading)
        XCTAssertFalse(performLoginCalled)
        XCTAssertFalse(onSuccessCalled)
    }

    func test_login_whenCredentialsAreValid_callsPerformLogin_withTrimmedValues_andCallsOnSuccess() async {
        // given
        var capturedEmail: String?
        var capturedPassword: String?

        let sut = LoginViewModel { email, password in
            capturedEmail = email
            capturedPassword = password
        }

        sut.email = "  user@example.com "
        sut.password = "  123456  "

        var onSuccessCalled = false

        // when
        await sut.login {
            onSuccessCalled = true
        }

        // then
        XCTAssertNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
        XCTAssertTrue(onSuccessCalled)

        XCTAssertEqual(capturedEmail, "user@example.com")
        XCTAssertEqual(capturedPassword, "123456")
    }

    func test_login_whenAuthErrorInvalidCredentials_setsSpecificErrorMessage_andDoesNotCallOnSuccess() async {
        // given
        let sut = LoginViewModel { _, _ in
            throw AuthError.invalidCredentials
        }

        sut.email = "user@example.com"
        sut.password = "123456"

        var onSuccessCalled = false

        // when
        await sut.login {
            onSuccessCalled = true
        }

        // then
        XCTAssertEqual(
            sut.errorMessage,
            AuthError.invalidCredentials.errorDescription
        )
        XCTAssertFalse(sut.isLoading)
        XCTAssertFalse(onSuccessCalled)
    }

    func test_login_whenUnexpectedErrorOccurs_setsGenericErrorMessage() async {
        // given
        struct DummyError: Error {}

        let sut = LoginViewModel { _, _ in
            throw DummyError()
        }

        sut.email = "user@example.com"
        sut.password = "123456"

        var onSuccessCalled = false

        // when
        await sut.login {
            onSuccessCalled = true
        }

        // then
        XCTAssertEqual(sut.errorMessage, AuthErrorKey.unexpected)
        XCTAssertFalse(sut.isLoading)
        XCTAssertFalse(onSuccessCalled)
    }
     
}
