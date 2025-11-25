//
//  ViewCoding.swift
//  PaymentWallet
//
//  Created by Marcello Chuahy on 25/11/25.
//

import UIKit

/// Protocol that defines the standard setup steps for view code.
///
/// The default implementation of `setupView()` guarantees the correct order:
/// 1. buildViewHierarchy()
/// 2. setupConstraints()
/// 3. setupAdditionalConfiguration()
protocol ViewCoding {
    /// Adds subviews and defines the view hierarchy.
    func buildViewHierarchy()

    /// Activates Auto Layout constraints.
    func setupConstraints()

    /// Applies additional configuration such as background color, accessibility, etc.
    func setupAdditionalConfiguration()
}

extension ViewCoding {
    /// Orchestrates the view setup in the correct and predictable order.
    func setupView() {
        buildViewHierarchy()
        setupConstraints()
        setupAdditionalConfiguration()
    }
}
