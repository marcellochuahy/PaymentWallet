//
//  WalletFeatureSampleAppApp.swift
//  WalletFeatureSampleApp
//
//  Created by Marcello Chuahy on 26/11/25.
//

import SwiftUI

@main
struct WalletFeatureSampleAppApp: App {
    
    let userMock = WalletFeatureEntryPoint.UserInfo(name: "Wolfgang Amadeus Mozart", email: "user@example.com")
    let balanceMock: Decimal = 1234.56
    let contactsMock = [
        WalletFeatureEntryPoint.Contact(name: "Ludwig van Beethoven", email: "ludwig@example.com", accountDescription: "Conta corrente: R$ 1.804,37"),
        WalletFeatureEntryPoint.Contact(name: "Clara Schumann", email: "clara@example.com", accountDescription: "Poupança: R$ 1.841,56"),
        WalletFeatureEntryPoint.Contact(name: "Hildegard von Bingen", email: "hildegard@example.com", accountDescription: "Conta do mosteiro: R$ 1.151,49")
    ]
    
    var body: some Scene {
        WindowGroup {
            WalletFeatureEntryPoint.makeHomeView(
                user: userMock,
                loadBalance: { balanceMock },
                loadContacts: { contactsMock },
                onSelectContact: { contact in
                    print("Selecionou contato:", contact.name)
                }
            )
        }
    }
}
