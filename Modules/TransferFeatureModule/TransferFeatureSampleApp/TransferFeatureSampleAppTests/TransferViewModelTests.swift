//
//  TransferViewModelTests.swift
//  TransferFeatureSampleAppTests
//
//  Created by Marcello Chuahy on 26/11/25.
//

import XCTest
@testable import TransferFeature

@MainActor
final class TransferViewModelTests: XCTestCase {

    // MARK: - Test Doubles

    /// Actor spy that records calls to performTransfer in a concurrency-safe way.
    actor TransferSpy {
        private(set) var calls: [(beneficiary: TransferFeatureEntryPoint.Beneficiary,
                                  amount: Decimal)] = []

        var result: Result<Void, Error> = .success(())

        func record(_ beneficiary: TransferFeatureEntryPoint.Beneficiary,
                    _ amount: Decimal) throws {
            calls.append((beneficiary, amount))
            if case let .failure(error) = result {
                throw error
            }
        }
    }

    // MARK: - Helpers

    private func makeBeneficiaries() -> [TransferFeatureEntryPoint.Beneficiary] {
        [
            .init(
                name: "Wolfgang Amadeus Mozart",
                accountDescription: "1234-5 · Salzburg Bank"
            ),
            .init(
                name: "Ludwig van Beethoven",
                accountDescription: "6789-0 · Bonn Bank"
            )
        ]
    }

    private func makeSUT(
        beneficiaries: [TransferFeatureEntryPoint.Beneficiary]? = nil
    ) -> (sut: TransferViewModel, spy: TransferSpy) {

        let list = beneficiaries ?? makeBeneficiaries()
        let spy = TransferSpy()

        let viewModel = TransferViewModel(
            beneficiaries: list,
            performTransfer: { beneficiary, amount in
                try await spy.record(beneficiary, amount)
            }
        )

        return (viewModel, spy)
    }

    // MARK: - Tests

    func test_submitTransfer_whenNoBeneficiarySelected_setsErrorAndDoesNotCallTransfer() async {
        // GIVEN
        let (sut, spy) = makeSUT()
        sut.selectedBeneficiaryID = nil
        sut.amountText = "100,00"

        // WHEN
        await sut.submitTransfer(onSuccess: {})

        // THEN
        XCTAssertEqual(
            sut.errorMessage,
            "Selecione um beneficiário."
        )

        let calls = await spy.calls
        XCTAssertTrue(
            calls.isEmpty,
            "performTransfer should not be called when no beneficiary is selected."
        )
    }

    func test_submitTransfer_whenInvalidAmount_setsErrorAndDoesNotCallTransfer() async {
        // GIVEN
        let (sut, spy) = makeSUT()
        sut.selectedBeneficiaryID = sut.beneficiaries.first?.id
        sut.amountText = "abcxyz" // invalid

        // WHEN
        await sut.submitTransfer(onSuccess: {})

        // THEN
        XCTAssertEqual(
            sut.errorMessage,
            "Digite um valor válido."
        )

        let calls = await spy.calls
        XCTAssertTrue(
            calls.isEmpty,
            "performTransfer should not be called when the amount is invalid."
        )
    }

    func test_submitTransfer_whenZeroAmount_setsErrorAndDoesNotCallTransfer() async {
        // GIVEN
        let (sut, spy) = makeSUT()
        sut.selectedBeneficiaryID = sut.beneficiaries.first?.id
        sut.amountText = "0,00"

        // WHEN
        await sut.submitTransfer(onSuccess: {})

        // THEN
        XCTAssertEqual(
            sut.errorMessage,
            "O valor deve ser maior que zero."
        )

        let calls = await spy.calls
        XCTAssertTrue(
            calls.isEmpty,
            "performTransfer should not be called when amount is zero."
        )
    }

    func test_submitTransfer_whenValidInput_callsTransferWithParsedAmountAndClearsError() async throws {
        // GIVEN
        let (sut, spy) = makeSUT()
        let selected = sut.beneficiaries[0]

        sut.selectedBeneficiaryID = selected.id
        sut.amountText = "1.234,56" // pt_BR format

        // WHEN
        await sut.submitTransfer(onSuccess: { })

        // THEN
        XCTAssertNil(
            sut.errorMessage,
            "Error message should be nil on successful transfer."
        )

        let calls = await spy.calls
        XCTAssertEqual(calls.count, 1, "Expected exactly one transfer call.")

        let firstCall = try XCTUnwrap(calls.first)
        XCTAssertEqual(firstCall.beneficiary, selected)

        // 1.234,56 => 1234.56
        let expected = Decimal(string: "1234.56")!
        XCTAssertEqual(firstCall.amount, expected, "Amount should be parsed correctly from pt_BR format.")
    }

    func test_parseAmount_acceptsPtBRFormat() {
        let value = TransferViewModel.parseAmount(from: "1.234,56")
        XCTAssertEqual(value, Decimal(string: "1234.56"))
    }

    func test_parseAmount_acceptsSimpleDecimalWithDot() {
        let value = TransferViewModel.parseAmount(from: "1234.56")
        XCTAssertEqual(value, Decimal(string: "1234.56"))
    }

    func test_parseAmount_returnsNilForEmptyString() {
        let value = TransferViewModel.parseAmount(from: "   ")
        XCTAssertNil(value)
    }
}
