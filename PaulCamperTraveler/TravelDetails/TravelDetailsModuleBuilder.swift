//
//  TravelDetailsModuleBuilder.swift
//  PaulCamperTraveler
//
//  Created by Сергей Курочкин on 25/12/2018.
//  Copyright © 2018 Сергей Курочкин. All rights reserved.
//

import UIKit


struct TravelDetailsModule {
    let router: TravelRouter
    let viewModel: DetailsViewModel
    let viewController: DetailsViewController
    let cell: UIView

    init(cell: UIView, travel: Travel) {
        router = TravelRouter()
        viewModel = DetailsViewModel(router: router, travel: travel)
        viewController = DetailsViewController(viewModel: viewModel)
        router.viewController = viewController
        self.cell = cell
    }
}
