//
//  Transition.swift
//  PaulCamperTraveler
//
//  Created by Сергей Курочкин on 23/12/2018.
//  Copyright © 2018 Сергей Курочкин. All rights reserved.
//

import UIKit

protocol Transition: class {
    var  viewController: UIViewController? { get set }

    func open(_ viewController: UIViewController)
    func close(_ viewController: UIViewController)
}
