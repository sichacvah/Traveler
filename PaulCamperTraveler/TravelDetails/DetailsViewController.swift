//
//  DetailsViewController.swift
//  PaulCamperTraveler
//
//  Created by Сергей Курочкин on 21/12/2018.
//  Copyright © 2018 Сергей Курочкин. All rights reserved.
//

import UIKit
import Nuke

class DetailsViewController: UIViewController, UIGestureRecognizerDelegate {
    public var viewModel: DetailsViewModel?
    private let titleView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.numberOfLines = 2
        return label
    }()
    
    public func setCornerRadius(_ radius: CGFloat) {
        cardContentView.layer.cornerRadius = 14
    }

    private let closeView: UIButton = {
        let view = UIButton()
        view.setTitle("✕", for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 14
        view.clipsToBounds = true
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blur.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(blur, at: 0)
        blur.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        blur.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        blur.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        blur.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        blur.alpha = 0.7
        blur.isUserInteractionEnabled = false
        return view
    }()
    
    private lazy var descriptionView: UILabel = {
        let description = UILabel()
        description.translatesAutoresizingMaskIntoConstraints = false
        description.font = UIFont.systemFont(ofSize: 18, weight: .light)
        description.shadowColor = UIColor.black
        description.shadowOffset = CGSize.zero
        description.textColor = .lightGray
        description.adjustsFontSizeToFitWidth = true
        description.lineBreakMode = .byTruncatingTail
        description.numberOfLines = 0
        description.textAlignment = .left
        return description
    }()

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.contentInsetAdjustmentBehavior = .never
        return scrollView
    }()
    
    public let cardContentView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 14
        view.backgroundColor = .white
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    public func setScrollViewDelegate(delegate: UIScrollViewDelegate) {
        self.scrollView.delegate = delegate
    }
    
    public func getScrollView() -> UIScrollView {
        return self.scrollView
    }
    
    var statusBarStyle: UIStatusBarStyle = .lightContent
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    init(viewModel: DetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .none
        setupView()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        scrollView.scrollIndicatorInsets = .init(top: max(-view.safeAreaInsets.top,0), left: 0, bottom: 0, right: 0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIView.animate(withDuration: 0.2, animations: {
            self.closeView.alpha = 0
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        UIView.animate(withDuration: 0.2, animations: {
            self.closeView.alpha = 1
        })
    }
    
    public let imageView = UIImageView()

    private let dumbView = UIView()
    
    @objc func handleClose(sender: UIButton!) {
        viewModel?.router.close()
    }
    
    private func setupView() {
        view.addSubview(cardContentView)
        cardContentView.edges(to: view)
        
        cardContentView.addSubview(scrollView)

        scrollView.leadingAnchor.constraint(equalTo: cardContentView.leadingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: cardContentView.topAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: cardContentView.trailingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: cardContentView.bottomAnchor).isActive = true
        scrollView.addSubview(imageView)
        scrollView.clipsToBounds = true

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: cardContentView.heightAnchor, multiplier: 0.6).isActive = true
        imageView.leadingAnchor.constraint(equalTo: cardContentView.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: cardContentView.trailingAnchor).isActive = true
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        if let urlString = viewModel?.travel.getPreviewPhoto()?.urlString, let url = URL(string: urlString) {
            Nuke.loadImage(with: url, into: imageView)
        }
        scrollView.addSubview(titleView)
        
        titleView.text = viewModel?.travel.name
        descriptionView.text = viewModel?.travel.description
        
        titleView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16).isActive = true
        titleView.leadingAnchor.constraint(equalTo: cardContentView.leadingAnchor, constant: 16).isActive = true
        titleView.trailingAnchor.constraint(equalTo: cardContentView.trailingAnchor, constant: -16).isActive = true
        
        scrollView.addSubview(descriptionView)
        descriptionView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 16).isActive = true
        descriptionView.leadingAnchor.constraint(equalTo: cardContentView.leadingAnchor, constant: 16).isActive = true
        descriptionView.trailingAnchor.constraint(equalTo: cardContentView.trailingAnchor, constant: -16).isActive = true
        descriptionView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16).isActive = true
        cardContentView.addSubview(closeView)
        closeView.alpha = 0
        closeView.widthAnchor.constraint(equalToConstant: 28).isActive = true
        closeView.heightAnchor.constraint(equalToConstant: 28).isActive = true
        closeView.topAnchor.constraint(equalTo: cardContentView.topAnchor, constant: 20).isActive = true
        closeView.rightAnchor.constraint(equalTo: cardContentView.rightAnchor, constant: -20).isActive = true
        closeView.addTarget(self, action: #selector(handleClose), for: .touchUpInside)
        view.clipsToBounds = false
    }
    
}

