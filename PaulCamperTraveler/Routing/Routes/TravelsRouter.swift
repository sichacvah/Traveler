//
//  TravelsRouter.swift
//  PaulCamperTraveler
//
//  Created by Сергей Курочкин on 25/12/2018.
//  Copyright © 2018 Сергей Курочкин. All rights reserved.
//

import UIKit

final class TravelsRouter: Router<TravelCollectionViewController>, TravelsRouter.Routes {
    typealias Routes = TravelRoute
    var travelTransition: Transition {
        return PushTransition()
    }
}
