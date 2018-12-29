//
//  TravelCellViewModel.swift
//  PaulCamperTraveler
//
//  Created by Сергей Курочкин on 19/12/2018.
//  Copyright © 2018 Сергей Курочкин. All rights reserved.
//

import UIKit

protocol CellViewAnyModel {
    static var cellAnyType: UIView.Type { get }
    func setupAny(cell: UIView)
}

protocol CellViewModel: CellViewAnyModel {
    associatedtype CellType: UIView
    func setup(cell: CellType)
}

extension CellViewModel {
    static var cellAnyType: UIView.Type {
        return CellType.self
    }
    func setupAny(cell: UIView) {
        setup(cell: cell as! CellType)
    }
}


struct TravelCollectionViewCellModel: CellViewAnyModel {
    let photoImage: String?
    let label: String
    let description: String
}

extension TravelCollectionViewCellModel: CellViewModel {
    func setup(cell: TravelCollectionViewCell) {
        cell.imageUrlString = self.photoImage
        cell.cardView.descriptionText = self.description
        cell.cardView.label = self.label
    }
}

extension UICollectionView {
    func dequeueReusableCell(withModel model: CellViewAnyModel, for indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = String(describing: type(of: model).cellAnyType)
        let cell = self.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        
        model.setupAny(cell: cell)
        
        return cell
    }
}
