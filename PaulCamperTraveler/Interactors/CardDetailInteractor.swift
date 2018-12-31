//
//  CardDetailInteractor.swift
//  PaulCamperTraveler
//
//  Created by Сергей Курочкин on 29/12/2018.
//  Copyright © 2018 Сергей Курочкин. All rights reserved.
//

import UIKit

protocol Interactor: UIViewControllerInteractiveTransitioning {
    var transitionInProgress: Bool { get }
}

final class DismissalPanGesture: UIPanGestureRecognizer {}
final class DismissalScreenEdgePanGesture: UIScreenEdgePanGestureRecognizer {}

class CardDetailInteractor: NSObject, Interactor {
    var transitionInProgress: Bool = false
    var draggingDownToDismiss: Bool = false
    let params: AnimationParams
    let viewModel: DetailsViewModel?
    var transitionContext: UIViewControllerContextTransitioning?
    var interactiveStartingPoint: CGPoint?
    public var wantsInteractiveStart = true
    fileprivate var animator: UIViewImplicitlyAnimating?
    var scrollView: UIScrollView
    
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
    
    init?(attachTo viewController: UIViewController, params: AnimationParams) {
        if let vc = viewController as? DetailsViewController {
            self.params = params
            self.viewModel = vc.viewModel
            self.scrollView = vc.getScrollView()
            super.init()
            vc.setScrollViewDelegate(delegate: self)

            setupBackGesture(view: vc.view)
        } else {
            return nil
        }
    }
    
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.animator = animator(using: transitionContext)
    }
    
    fileprivate func setupBackGesture(view: UIView) {
        dismissalScreenEdgePanGesture.addTarget(self, action: #selector(handleBackGesture(gesture:)))
        dismissalScreenEdgePanGesture.delegate = self
        
        dismissalPanGesture.addTarget(self, action: #selector(handleBackGesture(gesture:)))
        dismissalPanGesture.delegate = self
        
        dismissalPanGesture.require(toFail: dismissalScreenEdgePanGesture)
        scrollView.panGestureRecognizer.require(toFail: dismissalScreenEdgePanGesture)
        
        view.addGestureRecognizer(dismissalPanGesture)
        view.addGestureRecognizer(dismissalScreenEdgePanGesture)
    }
    
    func animator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        self.transitionContext = transitionContext
        let fromScreen = transitionContext.viewController(forKey: .from) as! DetailsViewController
        let toScreen = transitionContext.viewController(forKey: .to)
        let fromView = fromScreen.view!
        let toView = toScreen!.view!
        let containerView = transitionContext.containerView
        containerView.insertSubview(toView, at: 0)
        let blurEffect = UIBlurEffect(style: .prominent)
        
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = transitionContext.containerView.bounds
        containerView.insertSubview(blurEffectView, at: 1)

        let animator = UIViewPropertyAnimator(duration: 0, curve: .linear, animations: {
            fromView.transform = .init(scaleX: 0.86, y: 0.86)
            fromScreen.cardContentView.layer.cornerRadius = 14
        })
        
        animator.addCompletion { _ in
            
            if transitionContext.transitionWasCancelled {
                UIView.animate(withDuration: 0.16, animations: {
                    fromScreen.cardContentView.layer.cornerRadius = 0
                    fromView.transform = .identity
                }, completion: { _ in
                    blurEffectView.removeFromSuperview()
                    toView.removeFromSuperview()
                    transitionContext.completeTransition(false)
                })
            } else {
                blurEffectView.removeFromSuperview()
                CardDismissAnimation.animate(fromView, params: self.params, container: containerView, cardContentView: fromScreen.cardContentView, completion: {
                    transitionContext.completeTransition(true)
                })
                
            }
            self.animator = nil
            
        }
        animator.isReversed = false
        animator.pauseAnimation()
        animator.fractionComplete = 0.0
        return animator
    }
    
    func updateInteractiveTransition(_ progress: CGFloat) {
        transitionContext?.updateInteractiveTransition(progress)
        self.animator?.fractionComplete = progress
        if progress > 1.0 {
            self.transitionContext?.finishInteractiveTransition()
            self.animator?.stopAnimation(false)
            self.animator?.finishAnimation(at: .end)
        }
    }
    
    func finishInteractiveTransition() {
        guard let transitionContext = self.transitionContext else { return }
        transitionContext.finishInteractiveTransition()
        draggingDownToDismiss = false
        self.animator?.stopAnimation(false)
        self.animator?.finishAnimation(at: .end)
    }
    
    func cancelInteractiveTransition() {
        guard let transitionContext = self.transitionContext else { return }
        transitionContext.cancelInteractiveTransition()
        draggingDownToDismiss = false
        self.animator?.fractionComplete = 0.0
        self.animator?.stopAnimation(false)
        self.animator?.finishAnimation(at: .current)
    }
    
    
    @objc func handleBackGesture(gesture: UIPanGestureRecognizer) {
//        let viewTransition = gesture.translation(in: gesture.view?.superview)
        let isScreenEdgePan = gesture.isKind(of: DismissalScreenEdgePanGesture.self)
        let canStartDragDownToDismissPan = !isScreenEdgePan && !self.draggingDownToDismiss
        if canStartDragDownToDismissPan { return }
        
        let startingPoint: CGPoint
        
        let targetAnimatedView = gesture.view!
        if let p = self.interactiveStartingPoint {
            startingPoint = p
        } else {
            // Initial location
            startingPoint = gesture.location(in: nil)
            self.interactiveStartingPoint = startingPoint
        }
        let currentLocation = gesture.location(in: nil)

        let progress = isScreenEdgePan ? (gesture.translation(in: targetAnimatedView).x / 100) : (currentLocation.y - startingPoint.y) / 100

        print("STATE", gesture.state.rawValue)
        
        switch gesture.state {
        case .began:
            transitionInProgress = true
            viewModel?.closeEvent()
            break
        case .changed:
            updateInteractiveTransition(progress)
            break
        case .cancelled:
            transitionInProgress = false
            cancelInteractiveTransition()
            break
        case .ended:
            transitionInProgress = false
            progress > 1.0 ? finishInteractiveTransition() : cancelInteractiveTransition()
            break
//        default:
        default:
            fatalError("Impossible gesture state? \(gesture.state.rawValue)")
        }
    }
}

extension CardDetailInteractor: UIScrollViewDelegate {

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if velocity.y > 0 && scrollView.contentOffset.y <= 0 {
            scrollView.contentOffset = .zero
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.draggingDownToDismiss || (scrollView.isTracking && scrollView.contentOffset.y < 0) {
            if !self.draggingDownToDismiss {
                transitionInProgress = true
                viewModel?.closeEvent()
            }
            self.draggingDownToDismiss = true
            scrollView.contentOffset = .zero
            
        }
        
        scrollView.showsVerticalScrollIndicator = !self.draggingDownToDismiss
    }
}


extension CardDetailInteractor: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
