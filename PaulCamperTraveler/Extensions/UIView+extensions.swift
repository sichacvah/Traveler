//
//  UIView+extensions.swift
//  PaulCamperTraveler
//
//  Created by Сергей Курочкин on 19/12/2018.
//  Copyright © 2018 Сергей Курочкин. All rights reserved.
//

import UIKit


extension UIView {
    func addConstraintsWithFormat(_ format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            viewsDictionary[key] = view
        }
        
        addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: format,
            options: NSLayoutConstraint.FormatOptions(),
            metrics: nil,
            views: viewsDictionary
        ))
    }
}
