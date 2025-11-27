//
//  WalletFeatureSampleAppApp.swift
//  WalletFeatureSampleApp
//
//  Created by Marcello Chuahy on 26/11/25.
//

import SwiftUI

@main
struct WalletFeatureSampleAppApp: App {

    var body: some Scene {
        WindowGroup {
            WalletFeatureEntryPoint.makeHomeView(
                user: Constants.userMock,
                loadBalance: { Constants.balanceMock },
                loadContacts: { Constants.contactsMock },
                onSelectContact: { contact in
                    print("Selecionou contato:", contact.name)
                }
            )
        }
    }
}
