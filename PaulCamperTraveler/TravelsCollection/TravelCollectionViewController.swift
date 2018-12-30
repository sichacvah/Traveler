//
//  TravelCollectionViewController.swift
//  PaulCamperTraveler
//
//  Created by Сергей Курочкин on 19/12/2018.
//  Copyright © 2018 Сергей Курочкин. All rights reserved.
//

import UIKit

class TravelCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    var viewModel: TravelsViewModel?
    
    var statusBarStyle: UIStatusBarStyle = .default
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.register(TravelCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: TravelCollectionViewCellModel.CellType.self))
        collectionView?.backgroundColor = .white
        collectionView?.contentInset = UIEdgeInsets(top: 24, left: 0, bottom: 24, right: 0)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    let travels: [Travel] = Travel.testData()
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return travels.count
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let travel = travels[indexPath.row]
        let viewModel = TravelCollectionViewCellModel(
            photoImage: travel.getPreviewPhoto()?.urlString,
            label: travel.name,
            description: travel.description
        )
        return collectionView.dequeueReusableCell(withModel: viewModel, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 24
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: 450)
    }
    
    func selectTravel(travel: Travel, cell: UIView) {
        
        viewModel?.didSelectTravel(travel: travel, cell: cell)
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let travel = travels[indexPath.row]

        let cell = collectionView.cellForItem(at: indexPath) as! TravelCollectionViewCell
        self.selectTravel(travel: travel, cell: cell.cardView)
//        print(collectionView.contentOffset)
        
    }
}
