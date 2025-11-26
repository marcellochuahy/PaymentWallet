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
        WalletFeatureEntryPoint.Contact(name: "Ludwig van Beethoven"),
        WalletFeatureEntryPoint.Contact(name: "Clara Schumann"),
        WalletFeatureEntryPoint.Contact(name: "Hildegard von Bingen")
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
