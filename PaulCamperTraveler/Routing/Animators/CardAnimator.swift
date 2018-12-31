//
//  CardAnimator.swift
//  PaulCamperTraveler
//
//  Created by Сергей Курочкин on 25/12/2018.
//  Copyright © 2018 Сергей Курочкин. All rights reserved.
//

import UIKit


class PresentCardAnimator: NSObject, UIViewControllerAnimatedTransitioning, Animator {
    var isPresenting: Bool = true
    let params: AnimationParams
    
    var presentationAnimator: UIViewPropertyAnimator?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        let defaultDuration = 0.2
        if isPresenting {
            return presentationAnimator?.duration ?? defaultDuration
        } else {
            return defaultDuration
        }
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isPresenting {
            self.present(using: transitionContext)
        } else {
            self.dismiss(using: transitionContext)
        }
    }
    

    func dismiss(using transitionContext: UIViewControllerContextTransitioning) {
        let fromScreen = transitionContext.viewController(forKey: .from) as! DetailsViewController
        let toScreen = transitionContext.viewController(forKey: .to) as! TravelCollectionViewController
        
        let containerView = transitionContext.containerView
//        containerView.removeConstraints(containerView.constraints)
        let fromView = fromScreen.view!
        let toView = toScreen.view!
        containerView.addSubview(toView)
        CardDismissAnimation.animate(fromView, params: self.params, container: containerView, cardContentView: fromScreen.cardContentView, completion: {
            if transitionContext.transitionWasCancelled {
                containerView.addSubview(fromView)
                fromView.edges(to: containerView)
            } else {
                fromView.removeConstraints(fromView.constraints)
                fromView.removeFromSuperview()
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)

        })
        
//        fromView.translatesAutoresizingMaskIntoConstraints = false
//        containerView.addSubview(toView)
//        containerView.addSubview(fromView)
//
//        let topConstraint = fromView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0)
//        let widthContraint = fromView.widthAnchor.constraint(equalToConstant: containerView.frame.width)
//        let heightConstraint = fromView.heightAnchor.constraint(equalToConstant: containerView.frame.height)
//        let horizontalConstraint = fromView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
//        let constraints = [topConstraint, widthContraint, heightConstraint, horizontalConstraint]
//        NSLayoutConstraint.activate(constraints)
//
//        toScreen.statusBarStyle = .lightContent
//        toScreen.setNeedsStatusBarAppearanceUpdate()
//        containerView.layoutIfNeeded()
//
//        let duration = self.transitionDuration(using: transitionContext)
//
//        UIView.animate(withDuration: duration, animations: {
//            topConstraint.constant = self.fromCellFrame.minY
//            widthContraint.constant = self.fromCellFrame.width
//            heightConstraint.constant = self.fromCellFrame.height
//            fromView.transform = CGAffineTransform.identity
//            fromView.layer.cornerRadius = 14
//            containerView.layoutIfNeeded()
//            toScreen.statusBarStyle = .default
//            toScreen.setNeedsStatusBarAppearanceUpdate()
//        }, completion: { _ in
//            if transitionContext.transitionWasCancelled {
//                containerView.removeConstraints(containerView.constraints)
//                fromView.removeConstraints(constraints)
//                fromView.edges(to: containerView, top: 0)
//            }
//            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
//        })
        
    }
    
    func present(using transitionContext: UIViewControllerContextTransitioning) {
        let toScreen = transitionContext.viewController(forKey: .to) as! DetailsViewController
        let containerView = transitionContext.containerView
        let cardDetailView = toScreen.view!
        self.presentationAnimator = CardPresentationAnimation.createBaseSpringAnimator(fromFrame: self.params.frame)
        CardPresentationAnimation.animate(cardDetailView, params: self.params, cardContentView: toScreen.cardContentView, container: containerView, animator: presentationAnimator, completion: {
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        )
    }
    
    init(params: AnimationParams) {
        self.params = params
    }
    
    
    
    
}
