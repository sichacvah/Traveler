//
//  CardPresentationAnimator.swift
//  PaulCamperTraveler
//
//  Created by Сергей Курочкин on 24/12/2018.
//  Copyright © 2018 Сергей Курочкин. All rights reserved.
//

import UIKit

class CardPresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning, Animator {
    var isPresenting: Bool = true
    
    private let params: Params
    private let springAnimator: UIViewPropertyAnimator
    private let presentAnimationDuration: TimeInterval
    private var transitionDriver: PresentCardTransitionDriver?
    
    struct Params {
        let fromCardFrame: CGRect
        let fromCell: TravelCollectionViewCell
    }
    
    init(params: Params) {
        self.params = params
        self.springAnimator = CardPresentationAnimator.createBaseSpringAnimator(params: params)
        self.presentAnimationDuration = springAnimator.duration
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return presentAnimationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        transitionDriver = PresentCardTransitionDriver(params: params, transitionContext: transitionContext, baseAnimator: springAnimator)
        interruptibleAnimator(using: transitionContext).startAnimation()
    }
    
    func animationEnded(_ transitionCompleted: Bool) {
        // 4.
        transitionDriver = nil
    }
    
    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        // 3.
        return transitionDriver!.animator
    }
    
    private static func createBaseSpringAnimator(params: CardPresentationAnimator.Params) -> UIViewPropertyAnimator {
        let cardPositionY = params.fromCardFrame.minY
        let distanceToBounce = abs(cardPositionY)
        let extentToBounce = cardPositionY < 0 ? params.fromCardFrame.height : UIScreen.main.bounds.height
        let dampFactorInterval: CGFloat = 0.3
        let damping: CGFloat = 1.0 - dampFactorInterval * ( distanceToBounce / extentToBounce )
        
        let baselineDuration: TimeInterval = 0.5
        let maxDuration: TimeInterval = 0.9
        
        let duration: TimeInterval = baselineDuration + (maxDuration - baselineDuration) * TimeInterval(max(0, distanceToBounce)/UIScreen.main.bounds.height)
        
        let springTiming = UISpringTimingParameters(dampingRatio: damping, initialVelocity: .init(dx: 0, dy: 0))
        
        return UIViewPropertyAnimator(duration: duration, timingParameters: springTiming)
    }
    
    
}

final class PresentCardTransitionDriver {
    let animator: UIViewPropertyAnimator
    init(params: CardPresentationAnimator.Params, transitionContext: UIViewControllerContextTransitioning, baseAnimator: UIViewPropertyAnimator) {
        let ctx = transitionContext
        let container = ctx.containerView
        let screens: (home: TravelCollectionViewController, cardDetail: DetailsViewController) = (
            ctx.viewController(forKey: .from) as! TravelCollectionViewController,
            ctx.viewController(forKey: .to) as! DetailsViewController
        )
        
        let cardDetailView = ctx.view(forKey: .to)!
        let cardFromView   = ctx.view(forKey: .from)!
        let fromCardFrame = params.fromCardFrame
        let animatedContainerView = UIView()
        
        animatedContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(animatedContainerView)
        
        do {
            let animatedContainerConstraints = [
                animatedContainerView.widthAnchor.constraint(equalToConstant: container.bounds.width),
                animatedContainerView.heightAnchor.constraint(equalToConstant: container.bounds.height),
                animatedContainerView.centerXAnchor.constraint(equalTo: container.centerXAnchor)
            ]
            NSLayoutConstraint.activate(animatedContainerConstraints)
        }
        
        let animatedContainerVerticalConstraint: NSLayoutConstraint = animatedContainerView.centerYAnchor.constraint(
            equalTo: container.centerYAnchor,
            constant: (fromCardFrame.height/2 + fromCardFrame.minY) - container.bounds.height/2
        )
        
        animatedContainerVerticalConstraint.isActive = true
        
        animatedContainerView.addSubview(cardDetailView)
        cardDetailView.translatesAutoresizingMaskIntoConstraints = false
        
        let weirdCardToAnimatedContainerTopAnchor: NSLayoutConstraint
        
        do {
            let verticalAnchor = cardDetailView.centerYAnchor.constraint(equalTo: animatedContainerView.centerYAnchor)
            let cardConstraints = [
                verticalAnchor,
                cardDetailView.centerXAnchor.constraint(equalTo: animatedContainerView.centerXAnchor)
            ]
            NSLayoutConstraint.activate(cardConstraints)
        }
        
        let cardWidthConstraint = cardDetailView.widthAnchor.constraint(equalToConstant: fromCardFrame.width)
        let cardHeightConstraint = cardDetailView.heightAnchor.constraint(equalToConstant: fromCardFrame.height)
        NSLayoutConstraint.activate([cardWidthConstraint, cardHeightConstraint])
        
        cardDetailView.layer.cornerRadius = 14.0
        
//        params.fromCell.isHidden = true
//        params.fromCell.resetTransform()
        let topTemporaryFix = screens.cardDetail.view.topAnchor.constraint(equalTo: cardDetailView.topAnchor, constant: 0)
        topTemporaryFix.isActive = true
        
        container.layoutIfNeeded()
        
        func animateContainerBouncingUp() {
            animatedContainerVerticalConstraint.constant = 0
            container.layoutIfNeeded()
        }
        
        func animateCardDetailViewSizing() {
            cardWidthConstraint.constant = animatedContainerView.bounds.width
            cardHeightConstraint.constant = animatedContainerView.bounds.height
            cardDetailView.layer.cornerRadius = 0
            container.layoutIfNeeded()
        }
        
        func completeEverything() {
            // Remove temporary `animatedContainerView`
            animatedContainerView.removeConstraints(animatedContainerView.constraints)
            animatedContainerView.removeFromSuperview()
            
            // Re-add to the top
            container.addSubview(cardDetailView)
            
            cardDetailView.removeConstraints([topTemporaryFix, cardWidthConstraint, cardHeightConstraint])
            
            // Keep -1 to be consistent with the weird bug above.
            cardDetailView.edges(to: container, top: -1)

            // No longer need the bottom constraint that pins bottom of card content to its root.
//            screens.cardDetail.cardBottomToRootBottomConstraint.isActive = false
//            screens.cardDetail.scrollView.isScrollEnabled = true
            
            let success = !ctx.transitionWasCancelled
            ctx.completeTransition(success)
        }
        
        baseAnimator.addAnimations {
            
            // Spring animation for bouncing up
            animateContainerBouncingUp()
            
            // Linear animation for expansion
            let cardExpanding = UIViewPropertyAnimator(duration: baseAnimator.duration * 0.6, curve: .linear) {
                animateCardDetailViewSizing()
            }
            cardExpanding.startAnimation()
        }
        
        baseAnimator.addCompletion { (_) in
            completeEverything()
        }
        
        self.animator = baseAnimator
    }
}


extension UIView {
    /// Constrain 4 edges of `self` to specified `view`.
    func edges(to view: UIView, top: CGFloat=0, left: CGFloat=0, bottom: CGFloat=0, right: CGFloat=0) {
        NSLayoutConstraint.activate([
            self.leftAnchor.constraint(equalTo: view.leftAnchor, constant: left),
            self.rightAnchor.constraint(equalTo: view.rightAnchor, constant: right),
            self.topAnchor.constraint(equalTo: view.topAnchor, constant: top),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: bottom)
        ])
    }
}
