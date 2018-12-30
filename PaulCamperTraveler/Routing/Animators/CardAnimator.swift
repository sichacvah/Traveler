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
    let fromCellFrame: CGRect
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
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
        containerView.removeConstraints(containerView.constraints)
        let fromView = fromScreen.view!
        let toView = toScreen.view!
        
        fromView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(toView)
        containerView.addSubview(fromView)
        
        let topConstraint = fromView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0)
        let widthContraint = fromView.widthAnchor.constraint(equalToConstant: containerView.frame.width)
        let heightConstraint = fromView.heightAnchor.constraint(equalToConstant: containerView.frame.height)
        let horizontalConstraint = fromView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        let constraints = [topConstraint, widthContraint, heightConstraint, horizontalConstraint]
        NSLayoutConstraint.activate(constraints)

        toScreen.statusBarStyle = .lightContent
        toScreen.setNeedsStatusBarAppearanceUpdate()
        containerView.layoutIfNeeded()
        
        let duration = self.transitionDuration(using: transitionContext)

        UIView.animate(withDuration: duration, animations: {
            topConstraint.constant = self.fromCellFrame.minY
            widthContraint.constant = self.fromCellFrame.width
            heightConstraint.constant = self.fromCellFrame.height
            fromView.transform = CGAffineTransform.identity
            fromView.layer.cornerRadius = 14
            containerView.layoutIfNeeded()
            toScreen.statusBarStyle = .default
            toScreen.setNeedsStatusBarAppearanceUpdate()
        }, completion: { _ in
            if transitionContext.transitionWasCancelled {
                containerView.removeConstraints(containerView.constraints)
                fromView.removeConstraints(constraints)
                fromView.edges(to: containerView, top: 0)
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
        
    }
    
    func present(using transitionContext: UIViewControllerContextTransitioning) {
//        let fromScreen = transitionContext.viewController(forKey: .from) as! TravelCollectionViewController
        let toScreen = transitionContext.viewController(forKey: .to) as! DetailsViewController
        let containerView = transitionContext.containerView
        
        let cardDetailView = toScreen.view!
//        let cardFromView   = fromScreen.view!
        let duration = self.transitionDuration(using: transitionContext)
        
        let finalDuration = duration * TimeInterval((containerView.bounds.height + fromCellFrame.minY) / containerView.bounds.height)
        
        let animationContainerView = UIView()
        animationContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(animationContainerView)
        animationContainerView.addSubview(cardDetailView)

        cardDetailView.translatesAutoresizingMaskIntoConstraints = false
        let widthContraint = animationContainerView.widthAnchor.constraint(equalToConstant: self.fromCellFrame.width)
        let heightConstraint = animationContainerView.heightAnchor.constraint(equalToConstant: self.fromCellFrame.height)
        let verticalConstraint = animationContainerView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: fromCellFrame.minY)
        let horizontalConstraint = animationContainerView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        let constraints = [widthContraint, heightConstraint, verticalConstraint, horizontalConstraint]
        NSLayoutConstraint.activate(constraints)
        
        let cardTopConstraint = cardDetailView.topAnchor.constraint(equalTo: animationContainerView.topAnchor, constant: -1)
        let cardBottomConstraint = cardDetailView.bottomAnchor.constraint(equalTo: animationContainerView.bottomAnchor)
        let cardLeadingConstrant = cardDetailView.leadingAnchor.constraint(equalTo: animationContainerView.leadingAnchor)
        let cardTrailingConstraint = cardDetailView.trailingAnchor.constraint(equalTo: animationContainerView.trailingAnchor)
        let cardConstraints = [cardTopConstraint, cardBottomConstraint, cardLeadingConstrant, cardTrailingConstraint]
        NSLayoutConstraint.activate(cardConstraints)
        
        cardDetailView.layer.cornerRadius = 16
        cardDetailView.clipsToBounds = true

        containerView.layoutIfNeeded()
        UIView.animate(withDuration: finalDuration, animations: {

            widthContraint.constant = containerView.bounds.width
            heightConstraint.constant = containerView.bounds.height
            verticalConstraint.constant = 0
            
            cardDetailView.layer.cornerRadius = 0
            toScreen.statusBarStyle = .lightContent
            toScreen.setNeedsStatusBarAppearanceUpdate()
            containerView.layoutIfNeeded()

        }, completion: { _ in
            cardDetailView.removeConstraints(cardConstraints)
            animationContainerView.removeConstraints(constraints)
            cardDetailView.removeFromSuperview()
            animationContainerView.removeFromSuperview()
            containerView.addSubview(cardDetailView)
            cardDetailView.edges(to: containerView, top: 0)
            containerView.layoutIfNeeded()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
//
        
    }
    
    init(fromCellFrame: CGRect) {
        self.fromCellFrame = fromCellFrame
    }
    
    
    
    
}
