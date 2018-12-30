//
//  CardDetailInteractor.swift
//  PaulCamperTraveler
//
//  Created by Сергей Курочкин on 29/12/2018.
//  Copyright © 2018 Сергей Курочкин. All rights reserved.
//

import UIKit
//UIPercentDrivenInteractiveTransition
class CardDetailInteractor: NSObject, UIViewControllerInteractiveTransitioning {
    public var wantsInteractiveStart: Bool {
        return true
    }

    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        self.animator = interruptibleAnimator(using: transitionContext)
    }
    
    func updateInteractiveTransition(_ progress: CGFloat) {
        transitionContext?.updateInteractiveTransition(progress)
        self.animator?.fractionComplete = progress
    }
    
    func finishInteractiveTransition() {
        guard let transitionContext = self.transitionContext else { return }
        transitionContext.finishInteractiveTransition()
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        self.animator?.fractionComplete = 1.0
        self.animator?.stopAnimation(false)
        self.animator?.finishAnimation(at: .end)
    }
    
    func cancelInteractiveTransition() {
        print("CANCEL")
        guard let transitionContext = self.transitionContext else { return }
        transitionContext.cancelInteractiveTransition()
        transitionContext.completeTransition(false)
        self.animator?.fractionComplete = 0.0
        self.animator?.stopAnimation(false)
        self.animator?.finishAnimation(at: .end)
        
    }
    
    
    private var progress: CGFloat = 0
    private var animator: UIViewImplicitlyAnimating?
    private var transitionContext: UIViewControllerContextTransitioning?
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    public func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        let fromScreen = transitionContext.viewController(forKey: .from) as! DetailsViewController
        let toScreen = transitionContext.viewController(forKey: .to)
        let fromView = fromScreen.view!
        let toView = toScreen!.view!
        let containerView = transitionContext.containerView
        containerView.insertSubview(toView, at: 0)
        let blurEffect = UIBlurEffect(style: .prominent)

        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = transitionContext.containerView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.insertSubview(blurEffectView, at: 1)
        let animator = UIViewPropertyAnimator(duration: 0, curve: .linear, animations: {
            fromView.transform = .init(scaleX: 0.86, y: 0.86)
            fromView.layer.cornerRadius = 14
        })
        
        animator.addCompletion { _ in
           
            if transitionContext.transitionWasCancelled {
//                fromView.edges(to: transitionContext.containerView, top: 0)
                blurEffectView.removeFromSuperview()
                toView.removeFromSuperview()
                fromView.layer.cornerRadius = 0
                fromView.transform = .identity
            } else {
                UIView.animate(withDuration: 0.2, animations: {
//                    blurEffectView.alpha = 0
                }, completion: { _ in
                    blurEffectView.removeFromSuperview()
                })
            }
            
        }
        animator.isReversed = false
        animator.pauseAnimation()
        animator.fractionComplete = progress
        return animator
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {}
    
    private weak var navigationController: UINavigationController?
    var shouldCompleteTransition = false
    var transitionInProgress = false
    
    init?(attachTo viewController: UIViewController) {
        if let nav = viewController.navigationController {
            self.navigationController = nav
            super.init()
            setupBackGesture(view: viewController.view)
        } else {
            return nil
        }
    }
    
    final class DismissalPanGesture: UIPanGestureRecognizer {}
    final class DismissalScreenEdgePanGesture: UIScreenEdgePanGestureRecognizer {}
    
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
        dismissalScreenEdgePanGesture.addTarget(self, action: #selector(handleBackGesture(gesture:)))
        view.addGestureRecognizer(dismissalScreenEdgePanGesture)
    }
    
    @objc private func handleBackGesture(gesture: UIScreenEdgePanGestureRecognizer) {
        let viewTransition = gesture.translation(in: gesture.view?.superview)
        let progress = viewTransition.x / self.navigationController!.view.frame.width
        
        switch gesture.state {
        case .began:
            transitionInProgress = true
            navigationController?.popViewController(animated: true)
            break
        case .changed:
            shouldCompleteTransition = progress > 0.5
            updateInteractiveTransition(progress)
            break
        case .cancelled:
            transitionInProgress = false
            cancelInteractiveTransition()
            break
        case .ended:
            transitionInProgress = false
            shouldCompleteTransition ? finishInteractiveTransition() : cancelInteractiveTransition()
            break
        default:
            return
        }
    }
}
