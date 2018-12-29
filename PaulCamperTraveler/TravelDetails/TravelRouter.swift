//
//  TravelRouter.swift
//  PaulCamperTraveler
//
//  Created by Сергей Курочкин on 25/12/2018.
//  Copyright © 2018 Сергей Курочкин. All rights reserved.
//

import UIKit

final class TravelRouter: Router<DetailsViewController> {
    typealias Routes = Closable
    var cell: UIView?
    
    init(cell: UIView) {
        self.cell = cell
    }
}

