//
//  LayoutHelper.swift
//  PaulCamperTraveler
//
//  Created by Сергей Курочкин on 21/12/2018.
//  Copyright © 2018 Сергей Курочкин. All rights reserved.
//

import Foundation
import UIKit

struct LayoutHelper {
    let rect: CGRect
    
    func X(_ persentage: CGFloat) -> CGFloat {
        return persentage * rect.width / 100
    }
    
    func Y(_ persentage: CGFloat) -> CGFloat {
        return persentage * rect.height / 100
    }
    
    func X(_ persentage: CGFloat, from: UIView) -> CGFloat {
        return X(persentage) + from.frame.maxX
    }
    
    func Y(_ persentage: CGFloat, from: UIView) -> CGFloat {
        return Y(persentage) + from.frame.maxY
    }
    
    func RevX(_ persentage: CGFloat, width: CGFloat) -> CGFloat {
        return (rect.width - X(persentage)) - width
    }
    
    func RevY(_ persentage: CGFloat, height: CGFloat) -> CGFloat {
        return (rect.height - Y(persentage)) - height
    }
    
    func Width(_ persentage: CGFloat, of view: UIView) -> CGFloat {
        return view.frame.width * (persentage / 100)
    }
    
    func Height(_ persentage: CGFloat, of view: UIView) -> CGFloat {
        return view.frame.height * (persentage / 100)
    }
    
    func XScreen(_ persentage: CGFloat) -> CGFloat {
        return persentage * UIScreen.main.bounds.height / 100
    }
    
    func YScreen(_ persentage: CGFloat) -> CGFloat {
        return persentage * UIScreen.main.bounds.width / 100
    }
}


extension CGRect {
    var center: CGPoint {
        return CGPoint(x: width/2 + minX, y: height/2 + minY)
    }
}
