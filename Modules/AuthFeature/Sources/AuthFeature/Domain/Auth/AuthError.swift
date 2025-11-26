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
            return "Please fill in all fields."
        case .invalidCredentials:
            return "Invalid credentials."
        case .unknown:
            return "An unknown error occurred."
        }
    }
}
