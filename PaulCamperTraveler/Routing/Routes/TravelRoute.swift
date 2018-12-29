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
    
    func getAnimator(cell: TravelCollectionViewCell) -> CardPresentationAnimator {
        let currentCellFrame = cell.layer.presentation()!.frame
        let cardPresentationFrameOnScreen = cell.superview!.convert(currentCellFrame, to: nil)
        let params = CardPresentationAnimator.Params(fromCardFrame: cardPresentationFrameOnScreen, fromCell: cell)
        return CardPresentationAnimator(params: params)
    }
    
    func openTravel(for travel: Travel, cell: UIView) {
        let detailsModule = TravelDetailsModule(cell: cell, travel: travel)
        let currentCellFrame = cell.layer.presentation()!.frame
        let cardPresentationFrameOnScreen = cell.superview!.convert(currentCellFrame, to: nil)
        let animator = PresentCardAnimator(fromCellFrame: cardPresentationFrameOnScreen)
        let transition = PushTransition(animator: animator, isAnimated: true)
        detailsModule.router.openTransition = transition
        detailsModule.viewController.modalPresentationStyle = .custom
        open(detailsModule.viewController, transition: transition)
    }

}

