//
//  OverlayWindow.swift
//  NetTrace
//
//  Created by Lyubomir Marinov on 4.12.25.
//

import UIKit

class OverlayWindow: UIWindow {
    
    private lazy var floatingButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.buttonSize = .large
        configuration.image = UIImage(systemName: "arrow.up.arrow.down.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 24))
        configuration.baseBackgroundColor = UIColor.label
        configuration.baseForegroundColor = UIColor.systemBackground
        configuration.contentInsets = .init(top: 4, leading: 4, bottom: 4, trailing: 4)
        configuration.imagePlacement = .leading
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(scale: .large)
        configuration.cornerStyle = .capsule
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.foregroundColor = UIColor.systemBackground
            outgoing.font = UIFont.boldSystemFont(ofSize: 13)
            return outgoing
        }
        
        let action = UIAction { [weak self] _ in
            self?.buttonTapped()
        }
        return UIButton(configuration: configuration, primaryAction: action)
    }()
    private var isShowingRequestList = false
    
    convenience init() {
        let connectedScenes = UIApplication.shared.connectedScenes
        
        if let windowScene = connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            self.init(windowScene: windowScene)
        } else if let windowScene = connectedScenes.first as? UIWindowScene {
            self.init(windowScene: windowScene)
        } else {
            self.init(frame: UIScreen.main.bounds)
        }
    }
    
    override init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)
        setupWindow()
        setupFloatingButton()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupWindow()
        setupFloatingButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupWindow() {
        backgroundColor = .clear
        windowLevel = .statusBar + 100
        
        let rootVC = UIViewController()
        rootVC.view.backgroundColor = .clear
        rootViewController = rootVC
    }
    
    private func setupFloatingButton() {
        guard let rootViewController else { return }
        
        rootViewController.view.addSubview(floatingButton)
        
        floatingButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            floatingButton.leadingAnchor.constraint(equalTo: rootViewController.view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            floatingButton.bottomAnchor.constraint(equalTo: rootViewController.view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            floatingButton.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        /// Listen for new network requests.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(requestsDidChange),
            name: NSNotification.Name("NetTraceRequestsChanged"),
            object: nil
        )
    }
    
    // MARK: - Actions
    
    @objc private func buttonTapped() {
        if isShowingRequestList {
            hideRequestList()
        } else {
            showRequestList()
        }
    }
    
    @objc private func requestsDidChange() {
        DispatchQueue.main.async {
            guard NetRecorder.shared.requests.count > 0 else {
                self.floatingButton.configuration?.title = nil
                self.floatingButton.configuration?.imagePadding = 0
                return
            }
            
            self.floatingButton.configuration?.title = String(format: "(%d)", NetRecorder.shared.requests.count)
            self.floatingButton.configuration?.imagePadding = 4
        }
    }
    
    private func showRequestList() {
        guard let rootVC = rootViewController else { return }
        
        let listVC = RequestListViewController()
        let navController = UINavigationController(rootViewController: listVC)
        navController.modalPresentationStyle = .fullScreen
        
        rootVC.present(navController, animated: true)
        isShowingRequestList = true
    }
    
    private func hideRequestList() {
        rootViewController?.dismiss(animated: true) {
            self.isShowingRequestList = false
        }
    }
    
    // MARK: - Show/Hide
    
    func show() {
        isHidden = false
    }
    
    func hide() {
        isHidden = true
    }
    
    // MARK: - Gestures handling.
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let rootView = rootViewController?.view else {
            return nil
        }
        
        let convertedPoint = rootView.convert(point, from: self)
        
        if floatingButton.frame.contains(convertedPoint) && floatingButton.isHidden == false {
            return super.hitTest(point, with: event)
        }
        
        if isShowingRequestList {
            return super.hitTest(point, with: event)
        }
        
        return nil
    }
}
