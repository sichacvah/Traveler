//
//  AppDelegate.swift
//  PaulCamperTraveler
//
//  Created by Сергей Курочкин on 19/12/2018.
//  Copyright © 2018 Сергей Курочкин. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow()
        window?.makeKeyAndVisible()
        let layout = UICollectionViewFlowLayout()
        let travelCollectionVC = TravelCollectionViewController(collectionViewLayout: layout)
        let router = TravelsRouter()
        router.viewController = travelCollectionVC
        let travelsViewModel = TravelsViewModel(router: router)
        travelCollectionVC.viewModel = travelsViewModel
        let navigationController = UINavigationController(rootViewController: travelCollectionVC)
        window?.rootViewController = navigationController
        return true
    }

}

