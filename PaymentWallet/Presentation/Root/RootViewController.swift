//
//  RootViewController.swift
//  PaymentWallet
//
//  Created by Marcello Chuahy on 25/11/25.
//

import UIKit

final class RootViewController: UIViewController {

    // MARK: - Properties

    private let customView = RootView()

    // MARK: - Lifecycle
    
    override func loadView() {
        view = customView
    }

}

final class RootView: UIView {
    
    // MARK: - Properties

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "PaymentWallet"
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - ViewCoding

extension RootView: ViewCoding {
    
    func buildViewHierarchy() {
        self.addSubview(titleLabel)
    }

    func setupConstraints() {
        let constraints = [
            titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }

    func setupAdditionalConfiguration() {
        self.backgroundColor = .systemBackground
    }

}
