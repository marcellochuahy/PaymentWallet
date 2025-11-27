//
//  TransferError.swift
//  PaymentWalletTests
//
//  Created by Marcello Chuahy on 27/11/25.
//

import Foundation

// MARK: - TransferError

/// Domain-level error for transfer operations.
/// Maps technical failures into user-facing messages.
enum TransferError: LocalizedError, Equatable {

    /// The authorization service denied the operation.
    case notAuthorized(reason: String?)

    /// There is not enough balance to complete the transfer.
    case insufficientBalance

    /// Fallback for unexpected failures.
    case unknown

    // MARK: - LocalizedError

    var errorDescription: String? {
        switch self {
        case .notAuthorized(let reason):
            // If backend/mocked service provides a reason, reuse it.
            if let reason, !reason.isEmpty {
                return reason
            }
            return NSLocalizedString(
                "transferError.notAuthorized",
                comment: "Generic unauthorized operation error"
            )

        case .insufficientBalance:
            return NSLocalizedString(
                "transferError.insufficientBalance",
                comment: "Insufficient balance to complete transfer"
            )

        case .unknown:
            return NSLocalizedString(
                "transferError.unknown",
                comment: "Unexpected transfer error"
            )
        }
    }
}
