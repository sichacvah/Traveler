//
//  TravelsViewModel.swift
//  PaulCamperTraveler
//
//  Created by Сергей Курочкин on 23/12/2018.
//  Copyright © 2018 Сергей Курочкин. All rights reserved.
//

import UIKit

class TravelsViewModel {
    private let router: TravelsRouter.Routes
    
    init(router: TravelsRouter.Routes) {
        self.router = router
    }
    
    func didSelectTravel(travel: Travel, cell: UIView) {
        router.openTravel(for: travel, cell: cell)
    }
}
