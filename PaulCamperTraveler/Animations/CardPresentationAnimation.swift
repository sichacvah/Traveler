//
//  CardPresentationAnimation.swift
//  PaulCamperTraveler
//
//  Created by Сергей Курочкин on 31/12/2018.
//  Copyright © 2018 Сергей Курочкин. All rights reserved.
//

import UIKit

struct AnimationParams {
    let cell: UIView
    let frame: CGRect
    let frameWithoutTransform: CGRect
    
    static let zero: AnimationParams = AnimationParams(cell: UIView(), frame: .zero, frameWithoutTransform: .zero)
}

class CardDismissAnimation {
    fileprivate struct AnimatedContainerConstraints {
        let topConstraint: NSLayoutConstraint
        let widthConstraint: NSLayoutConstraint
        let heightConstraint: NSLayoutConstraint
        
        func values() -> [NSLayoutConstraint] {
            return [topConstraint, widthConstraint, heightConstraint]
        }
        
        func activate() {
            NSLayoutConstraint.activate(values())
        }
    }
    static let dismissalAnimationDuration = 0.6
    
    static let animatedContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    fileprivate static func animateCardViewBackToPlace(_ view: UIView, fromFrame: CGRect, cardContentView: UIView, with animatedContainerConstraints: AnimatedContainerConstraints, container: UIView) {
        view.transform = .identity
        animatedContainerConstraints.topConstraint.constant = fromFrame.minY
        animatedContainerConstraints.widthConstraint.constant = fromFrame.width
        animatedContainerConstraints.heightConstraint.constant = fromFrame.height
        cardContentView.layer.cornerRadius = 14
        
        container.layoutIfNeeded()
    }
    
    
    static func animate(_ view: UIView, params: AnimationParams, container: UIView, cardContentView: UIView, completion: (() -> Void)?) {
        container.removeConstraints(container.constraints)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(animatedContainerView)
        animatedContainerView.addSubview(view)
        view.edges(to: animatedContainerView)
        

        animatedContainerView.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        let animatedContainerConstraints = AnimatedContainerConstraints(
            topConstraint: animatedContainerView.topAnchor.constraint(equalTo: container.topAnchor, constant: 0),
            widthConstraint: animatedContainerView.widthAnchor.constraint(equalToConstant: container.frame.width),
            heightConstraint: animatedContainerView.heightAnchor.constraint(equalToConstant: container.frame.height)
        )
        
        animatedContainerConstraints.activate()

        container.layoutIfNeeded()
        
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 24
        view.layer.shadowColor = UIColor.gray.cgColor
        view.layer.shadowOpacity = 0.4
        view.clipsToBounds = false
        
        UIView.animate(
            withDuration: dismissalAnimationDuration,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.0,
            options: [],
            animations: {
                animateCardViewBackToPlace(view, fromFrame: params.frameWithoutTransform, cardContentView: cardContentView, with: animatedContainerConstraints, container: container)
            },
            completion: { _ in
                animatedContainerView.removeConstraints(animatedContainerView.constraints)
                animatedContainerView.removeFromSuperview()
                params.cell.isHidden = false
                completion?()
            }
        )
    }
}

class CardPresentationAnimation {
    fileprivate struct AnimatedContainerConstraints {
        let widthConstraint: NSLayoutConstraint
        let heightConstraint: NSLayoutConstraint
        let verticalConstraint: NSLayoutConstraint
        let horizontalConstraint: NSLayoutConstraint
        
        func values() -> [NSLayoutConstraint] {
            return [
                widthConstraint,
                heightConstraint,
                verticalConstraint,
                horizontalConstraint
            ]
        }
    }
    
    fileprivate struct ViewConstraints {
        let widthConstraint: NSLayoutConstraint
        let heightConstraint: NSLayoutConstraint
        let centerXConstraint: NSLayoutConstraint
        let centerYConstraint: NSLayoutConstraint
        
        func values() -> [NSLayoutConstraint] {
            return [
                widthConstraint,
                heightConstraint,
                centerXConstraint,
                centerYConstraint
            ]
        }
    }
    
    static let dampFactorInterval: CGFloat = 0.3
    static let baselineDuration: TimeInterval = 0.5
    static let maxDuration: TimeInterval = 0.9

    static func animate(_ view: UIView, params: AnimationParams, cardContentView: UIView, container: UIView, animator: UIViewPropertyAnimator?, completion: (() -> Void)?) {
        let baseAnimator: UIViewPropertyAnimator = animator ?? CardPresentationAnimation.createBaseSpringAnimator(fromFrame: params.frame)
        let (viewConstraints, animatedContainerConstraints, animatedContainer) = CardPresentationAnimation.prepareAnimation(view: view, fromFrame: params.frame, containerView: container)
        baseAnimator.addAnimations {
            cardContentView.layer.cornerRadius = 0
            CardPresentationAnimation.animateContainerBouncingUp(container: container, animatedContainerConstraints: animatedContainerConstraints)
            
            let cardExpanding = UIViewPropertyAnimator(duration: baseAnimator.duration * 0.6, curve: .linear) {
                CardPresentationAnimation.animateCardViewSizing(view: view, viewConstraints: viewConstraints, container: container)
            }
            cardExpanding.startAnimation()
        }
        
        baseAnimator.addCompletion { _ in
            CardPresentationAnimation.completeAnimation(
                view: view,
                animatedContainerView: animatedContainer,
                containerView: container,
                viewConstraints: viewConstraints,
                animatedViewConstraints: animatedContainerConstraints,
                completion: completion
            )
        }
        params.cell.isHidden = true
        baseAnimator.startAnimation()
    }
    
    fileprivate static func completeAnimation(view: UIView, animatedContainerView: UIView, containerView: UIView, viewConstraints: ViewConstraints, animatedViewConstraints: AnimatedContainerConstraints, completion: (()-> Void)?) {
        animatedContainerView.removeConstraints(animatedContainerView.constraints)
        animatedContainerView.removeFromSuperview()

        containerView.addSubview(view)
        
        let cardConstraints = viewConstraints.values()
        let constraints = animatedViewConstraints.values()
        view.removeConstraints(cardConstraints)
        animatedContainerView.removeConstraints(constraints)
        view.removeFromSuperview()
        animatedContainerView.removeFromSuperview()
        containerView.addSubview(view)
        containerView.layoutIfNeeded()
        
        view.edges(to: containerView, top: -1)
        completion?()
    }
    
    static func createBaseSpringAnimator(fromFrame: CGRect) -> UIViewPropertyAnimator {
        let cardPositionY = fromFrame.minY
        let distanceToBounce = abs(cardPositionY)
        let extendToBounce = cardPositionY < 0 ? fromFrame.height : UIScreen.main.bounds.height
        let damping: CGFloat  = 1.0 - CardPresentationAnimation.dampFactorInterval * (distanceToBounce / extendToBounce)
        
        let duration: TimeInterval = baselineDuration + (maxDuration - baselineDuration) * TimeInterval(max(0, distanceToBounce) / UIScreen.main.bounds.height)
        
        let springTiming = UISpringTimingParameters(dampingRatio: damping, initialVelocity: .init(dx: 0, dy: 0))
        
        return UIViewPropertyAnimator(duration: duration, timingParameters: springTiming)
    }
    
    fileprivate static func animateContainerBouncingUp(container: UIView, animatedContainerConstraints: AnimatedContainerConstraints) {
        animatedContainerConstraints.verticalConstraint.constant = 0
        container.layoutIfNeeded()
    }
    
    fileprivate static func animateCardViewSizing(view: UIView, viewConstraints: ViewConstraints, container: UIView) {
        viewConstraints.widthConstraint.constant = container.bounds.width
        viewConstraints.heightConstraint.constant = container.bounds.height
        view.layer.cornerRadius = 0
        container.layoutIfNeeded()
    }
    
    fileprivate static func prepareAnimation(view: UIView, fromFrame: CGRect, containerView: UIView) -> (viewConstraints: ViewConstraints, animatedContainerConstraints: AnimatedContainerConstraints, animatedContainer: UIView) {
        let animationContainerView = UIView()
        animationContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(animationContainerView)
        animationContainerView.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        
        let widthContraint = animationContainerView.widthAnchor.constraint(equalToConstant: containerView.bounds.width)
        let heightConstraint = animationContainerView.heightAnchor.constraint(equalToConstant: containerView.bounds.height)

        let verticalConstraint = animationContainerView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: fromFrame.minY)
        let horizontalConstraint = animationContainerView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        let constraints = [widthContraint, heightConstraint, verticalConstraint, horizontalConstraint]
        NSLayoutConstraint.activate(constraints)
        let centerYAnchor = view.topAnchor.constraint(equalTo: animationContainerView.topAnchor)
        let widthAnchor = view.widthAnchor.constraint(equalToConstant: fromFrame.width)
        let heightAnchor = view.heightAnchor.constraint(equalToConstant: fromFrame.height)
        let centerXAnchor = view.centerXAnchor.constraint(equalTo: animationContainerView.centerXAnchor)
        let cardConstraints = [centerYAnchor, widthAnchor, heightAnchor, centerXAnchor]
        NSLayoutConstraint.activate(cardConstraints)
        
        containerView.layoutIfNeeded()
        return (
            viewConstraints: ViewConstraints(widthConstraint: widthAnchor, heightConstraint: heightAnchor, centerXConstraint: centerXAnchor, centerYConstraint: centerYAnchor),
            animatedContainerConstraints: AnimatedContainerConstraints(widthConstraint: widthContraint, heightConstraint: heightConstraint, verticalConstraint: verticalConstraint, horizontalConstraint: horizontalConstraint),
            animatedContainer: animationContainerView
        )
        
        
    }
}
