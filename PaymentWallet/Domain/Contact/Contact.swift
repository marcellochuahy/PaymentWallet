//
//  Contact.swift
//  PaymentWallet
//
//  Created by Marcello Chuahy on 25/11/25.
//

import Foundation

struct Contact: Identifiable, Equatable {
    let id: UUID
    let name: String
    let email: String
    let accountDescription: String

    init(
        id: UUID = UUID(),
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
