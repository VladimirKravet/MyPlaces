//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by Vladimir Kravets on 21.10.2022.
//


import UIKit

struct Place {
    
    var name : String
    var location : String?
    var type : String?
    var image: UIImage?
    var restaurantImage : String?
    
  static let restaurantNames = [
        "Burger Heroes", "Kitchen", "Bonsai", "Sherlock Holmes", "Speak Easy", "Morris Pub", "Love&Life"
    ]
    
static func getPlaces() -> [Place] {
    
    var places = [Place]()

    for place in restaurantNames {
        places.append(Place(name: place, location: "Vancuuver", type: "Restaurant", image: nil, restaurantImage: place))
    }
    
 return places
}
}
