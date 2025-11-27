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
        private(set) var calls: [(beneficiary: TransferFeatureEntryPoint.Beneficiary, amount: Decimal)] = []
        private var result: Result<Void, Error> = .success(())

        func record(_ beneficiary: TransferFeatureEntryPoint.Beneficiary, _ amount: Decimal) throws {
            calls.append((beneficiary, amount))
            if case let .failure(error) = result {
                throw error
            }
        }

        func setResult(_ newResult: Result<Void, Error>) {
            result = newResult
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

    enum ErrorKey {
        static let amountGreaterThanZero = "transfer.error.amountGreaterThanZero"
        static let invalidAmount         = "transfer.error.invalidAmount"
        static let invalidBeneficiary    = "transfer.error.invalidBeneficiary"
        static let noBeneficiary         = "transfer.error.noBeneficiary"
        static let unexpected            = "transfer.error.unexpected"
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
            ErrorKey.noBeneficiary
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
            ErrorKey.invalidAmount
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
            ErrorKey.amountGreaterThanZero
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

    func test_submitTransfer_whenPerformTransferThrowsLocalizedError_setsErrorMessageAndDoesNotCallOnSuccess() async {

        struct DummyTransferError: LocalizedError, Equatable {
            let message: String
            var errorDescription: String? { message }
        }

        // GIVEN
        let beneficiary = TransferFeatureEntryPoint.Beneficiary(
            id: UUID(),
            name: "Ludwig van Beethoven",
            accountDescription: "Conta corrente"
        )

        let beneficiaries = [beneficiary]
        let expectedError = DummyTransferError(message: "Saldo insuficiente.")
        let expectedAmount: Decimal = 100

        let (sut, spy) = makeSUT(beneficiaries: beneficiaries)

        // garante que estamos usando exatamente esse beneficiário
        sut.selectedBeneficiaryID = beneficiary.id
        sut.amountText = "100"

        await spy.setResult(.failure(expectedError))

        var onSuccessCalled = false

        // WHEN
        await sut.submitTransfer {
            onSuccessCalled = true
        }

        // THEN – performTransfer foi chamado com os dados corretos
        let calls = await spy.calls
        XCTAssertEqual(calls.count, 1, "performTransfer should be called exactly once.")
        let firstCall = calls.first.map { $0 }
        XCTAssertEqual(firstCall?.beneficiary.id, beneficiary.id)
        XCTAssertEqual(firstCall?.amount, expectedAmount)

        // erro veio do LocalizedError
        XCTAssertEqual(
            sut.errorMessage,
            expectedError.errorDescription,
            "errorMessage should use the errorDescription from LocalizedError."
        )

        XCTAssertFalse(onSuccessCalled, "onSuccess should not be called when performTransfer throws.")
        XCTAssertFalse(sut.isLoading, "isLoading should be false after submitTransfer finishes.")
    }
}

