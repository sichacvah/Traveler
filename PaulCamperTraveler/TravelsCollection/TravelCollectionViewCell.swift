//
//  TravelCollectionViewCell.swift
//  PaulCamperTraveler
//
//  Created by Сергей Курочкин on 19/12/2018.
//  Copyright © 2018 Сергей Курочкин. All rights reserved.
//

import UIKit

class TravelCollectionViewCell: UICollectionViewCell {

    public let cardView: Card = {
        let view = Card()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    func freezeAnimations() {
        cardView.freezeAnimations()
    }
    
    func unfreezeAnimations() {
        cardView.unfreezeAnimations()
    }
    

    var imageUrlString: String? {
        didSet {
            if cardView.backgroundImageUrlString != imageUrlString {
                cardView.backgroundImageUrlString = imageUrlString
            }
        }
    }

    

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        backgroundColor = .none
        addSubview(cardView)
        addConstraintsWithFormat("H:|-24-[v0]-24-|", views: cardView)
        addConstraintsWithFormat("V:|[v0]|", views: cardView)
    }
}

