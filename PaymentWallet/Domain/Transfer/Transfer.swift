//
//  Transfer.swift
//  PaymentWallet
//
//  Created by Marcello Chuahy on 25/11/25.
//

import Foundation

struct Transfer {
    
    let payer: User
    let payee: Contact
    let amount: Decimal

    init(payer: User, payee: Contact, amount: Decimal) {
        self.payer = payer
        self.payee = payee
        self.amount = amount
    }
    
}
