//
//  TravelRoute.swift
//  PaulCamperTraveler
//
//  Created by Сергей Курочкин on 23/12/2018.
//  Copyright © 2018 Сергей Курочкин. All rights reserved.
//

import UIKit

protocol TravelRoute {
    var travelTransition: Transition { get }
    func openTravel(for travel: Travel, cell: UIView)
}

extension TravelRoute where Self: RouterProtocol {
    var travelPresentationTransition: Transition {
        return PushTransition()
    }
    
    func openTravel(for travel: Travel, cell: UIView) {
        let detailsModule = TravelDetailsModule(cell: cell, travel: travel)
        let currentCellFrame = cell.layer.presentation()!.frame
        let cardPresentationFrameOnScreen = cell.superview!.convert(currentCellFrame, to: nil)
        
        let cardFrameWithoutTransform = { () -> CGRect in
            let center = cell.center
            let size = cell.bounds.size
            let r = CGRect(
                x: center.x - size.width / 2,
                y: center.y - size.height / 2,
                width: size.width,
                height: size.height
            )
            return cell.superview!.convert(r, to: nil)
        }()
        let params = AnimationParams(cell: cell, frame: cardPresentationFrameOnScreen, frameWithoutTransform: cardFrameWithoutTransform)
        let animator = PresentCardAnimator(params: params)
        let transition = PushTransition(animator: animator, isAnimated: true, params: params)
        detailsModule.router.openTransition = transition
        detailsModule.viewController.modalPresentationStyle = .custom
        open(detailsModule.viewController, transition: transition)
    }

}

