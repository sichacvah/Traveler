//
//  Travel.swift
//  PaulCamperTraveler
//
//  Created by Сергей Курочкин on 19/12/2018.
//  Copyright © 2018 Сергей Курочкин. All rights reserved.
//

import Foundation

struct Travel {
    let name: String
    let description: String
    let route: Route?
    let photos: [Photo]
    
    func getPreviewPhoto() -> Photo? {
        return self.photos.last
    }
    
    static func testData() -> [Travel] {
        return [
            Travel(
                name: "Travel from place A",
                description: "It is a long established fact that a reader will be distracted by the readable content of a",
                route: nil,
                photos: [Photo(urlString: "https://images.pexels.com/photos/1172064/pexels-photo-1172064.jpeg?auto=compress&cs=tinysrgb&dpr=2&w=320&h=240")]
            ),
            Travel(
                name: "Travel from place C to place D with route R",
                description: "It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less n",
                route: nil,
                photos: [Photo(urlString: "https://images.pexels.com/photos/574324/pexels-photo-574324.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=240&w=320")]
            ),
            Travel(
                name: "Travel from place F to place E with route R",
                description: "It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less n",
                route: nil,
                photos: [Photo(urlString: "https://images.pexels.com/photos/567952/pexels-photo-567952.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=240&w=320")]
            ),
            Travel(
                name: "Travel from place F to place E with route R",
                description: "It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less n",
                route: nil,
                photos: [Photo(urlString: "https://images.pexels.com/photos/1157940/pexels-photo-1157940.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=240&w=320")]
            )
        ]
    }
}

