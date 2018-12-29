//
//  CardDetailInteractor.swift
//  PaulCamperTraveler
//
//  Created by Сергей Курочкин on 29/12/2018.
//  Copyright © 2018 Сергей Курочкин. All rights reserved.
//

import UIKit

class CardDetailInteractor: UIPercentDrivenInteractiveTransition {
    private weak var navigationController: UINavigationController?
    var shouldCompleteTransition = false
    var transitionProgress = false
    
    init?(attachTo viewController: UIViewController) {
        if let nav = viewController.navigationController {
            self.navigationController = nav
            super.init()
            setupBackGesture(view: viewController.view)
        } else {
            return nil
        }
    }
    
    
    private lazy var dismissalPanGesture: DismissalPanGesture = {
        let pan = DismissalPanGesture()
        pan.maximumNumberOfTouches = 1
        return pan
    }()
    
    private lazy var dismissalScreenEdgePanGesture: DismissalScreenEdgePanGesture = {
        let pan = DismissalScreenEdgePanGesture()
        pan.edges = .left
        return pan
    }()
    
    private func setupBackGesture(view: UIView) {
        
    }
}
