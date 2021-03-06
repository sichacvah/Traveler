//
//  PushTransition.swift
//  PaulCamperTraveler
//
//  Created by Сергей Курочкин on 23/12/2018.
//  Copyright © 2018 Сергей Курочкин. All rights reserved.
//

import UIKit

class PushTransition: NSObject {
    var animator: Animator?
    var isAnimated: Bool = true
    var completionHandler: (() -> Void)?
    weak var viewController: UIViewController?
    var interactor: Interactor?
    let params: AnimationParams
    
    init(animator: Animator? = nil, isAnimated: Bool = true, params: AnimationParams = .zero) {
        self.animator = animator
        self.isAnimated = isAnimated
        self.params = params
    }
}

extension PushTransition: Transition {
    func open(_ viewController: UIViewController) {
        self.viewController?.navigationController?.delegate = self
        self.viewController?.navigationController?.pushViewController(viewController, animated: isAnimated)
    }
    
    func close(_ viewController: UIViewController) {
        self.viewController?.navigationController?.popViewController(animated: isAnimated)
    }
}

extension PushTransition: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        
        guard let interactor = self.interactor else { return nil }
        if interactor.transitionInProgress {
            return interactor
        } else {
            return nil
        }
        
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        completionHandler?()
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let animator = animator else {
            return nil
        }
        if operation == .push {
            self.interactor = CardDetailInteractor(attachTo: toVC, params: self.params)
            animator.isPresenting = true
            return animator
        } else {
            animator.isPresenting = false
            return animator
        }
    }
}
