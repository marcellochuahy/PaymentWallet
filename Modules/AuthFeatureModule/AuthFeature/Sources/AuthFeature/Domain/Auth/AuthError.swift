//
//  AuthError.swift
//  AuthFeature
//
//  Created by Marcello Chuahy on 25/11/25.
//

import Foundation

public enum AuthError: Error, LocalizedError {
    
    case missingCredentials
    case invalidCredentials
    case unknown

    public var errorDescription: String? {
        switch self {
        case .missingCredentials:
            return NSLocalizedString(
                "auth.error.emptyFields",
                comment: "Error when login fields are missing"
            )

        case .invalidCredentials:
            return NSLocalizedString(
                "auth.error.invalidCredentials",
                comment: "Error when credentials are invalid"
            )

        case .unknown:
            return NSLocalizedString(
                "auth.error.unexpected",
                comment: "Unexpected authentication error"
            )
        }
    }
}
