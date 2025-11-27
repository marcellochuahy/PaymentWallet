//
//  Constants.swift
//  WalletFeatureSampleAppTests
//
//  Created by Marcello Chuahy on 27/11/25.
//

import Foundation

enum Constants {
    
    static let userMock = UserInfoDataTransfer(name: "Wolfgang Amadeus Mozart", email: "user@example.com")
    
    static let balanceMock: Decimal = 1234.56
    
    static let contact1Mock = ContactDataTransfer(id: UUID(),
                                         name: "Ludwig van Beethoven",
                                         email: "ludwig@example.com",
                                         accountDescription: "Conta corrente 1234")
    
    static let contact2Mock = ContactDataTransfer(id: UUID(),
                                         name: "Clara Schumann",
                                         email: "clara@example.com",
                                         accountDescription: "Poupança 9876")
    
    static let contact3Mock = ContactDataTransfer(id: UUID(),
                                         name: "Hildegard von Bingen",
                                         email: "hildegard@example.com",
                                         accountDescription: "Conta corrente 5678")
    
    static let contactsMock: [ContactDataTransfer] = [contact1Mock, contact2Mock, contact3Mock]
        
}
