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
    private let dependencies: AppDependencies

    // MARK: - Initializers
    
    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func loadView() {
        view = customView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startLoginFlowIfNeeded()
    }
    
    // MARK: - Private Methods
    
    private func startLoginFlowIfNeeded() {
        guard let navigationController = navigationController else { return }
        
        let coordinator = LoginCoordinator(
            navigationController: navigationController,
            dependencies: dependencies
        )
        coordinator.start()
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
