//
//  DetailsViewModel.swift
//  PaulCamperTraveler
//
//  Created by Сергей Курочкин on 25/12/2018.
//  Copyright © 2018 Сергей Курочкин. All rights reserved.
//

import UIKit

struct DetailsViewModel {
    let router: TravelRouter.Routes
    let travel: Travel
    
    func closeEvent() {
        router.close()
    }
}
