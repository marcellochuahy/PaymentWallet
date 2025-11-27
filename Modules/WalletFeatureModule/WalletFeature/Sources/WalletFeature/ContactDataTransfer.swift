//
//  ContactDataTransfer.swift
//  WalletFeatureSampleApp
//
//  Created by Marcello Chuahy on 27/11/25.
//

import Foundation

/// DTO representing a contact coming from the Super App domain layer.
/// The Super App is responsible for creating and owning the `id`.
public struct ContactDataTransfer: Identifiable, Equatable, Sendable {
    
    public let id: UUID
    public let name: String
    public let email: String
    public let accountDescription: String

    /// Full initializer used by the Super App (with all fields).
    public init(
        id: UUID,
        name: String,
        email: String,
        accountDescription: String
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.accountDescription = accountDescription
    }
    
}
