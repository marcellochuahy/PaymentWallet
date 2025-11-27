//
//  TransferFeatureSampleAppApp.swift
//  TransferFeatureSampleApp
//
//  Created by Marcello Chuahy on 26/11/25.
//

import SwiftUI
import TransferFeature

@main
struct TransferFeatureSampleAppApp: App {

    // Example beneficiaries for the sample app.
    private let beneficiaries = [
        TransferFeatureEntryPoint.Beneficiary(
            name: "Ludwig van Beethoven",
            accountDescription: "Poupança: R$ 1.804,43"
        ),
        TransferFeatureEntryPoint.Beneficiary(
            name: "Clara Schumann",
            accountDescription: "Conta Corrente: R$ 3.841,18"
        ),
        TransferFeatureEntryPoint.Beneficiary(
            name: "Hildegard von Bingen",
            accountDescription: "Conta do Mosteiro: R$ 5.151,54"
        )
    ]

    var body: some Scene {
        WindowGroup {
            TransferFeatureEntryPoint.makeTransferView(
                beneficiaries: beneficiaries,
                preselectedBeneficiaryID: beneficiaries.first?.id,
                performTransfer: { beneficiary, amount in
                    // Simple demo implementation:
                    print("💸 SampleApp: transferring \(amount) to \(beneficiary.name)")
                },
                onTransferSuccess: {
                    print("✅ Transfer completed in SampleApp")
                }
            )
        }
    }
}
