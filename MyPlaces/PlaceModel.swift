//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by Vladimir Kravets on 21.10.2022.
//


import RealmSwift


class Place: Object {
    
    @objc dynamic var name = ""
    @objc dynamic var location : String?
    @objc dynamic var type : String?
    @objc dynamic var imageData: Data?
    @objc dynamic var date = Date()
    @objc dynamic var rating = 0.0
    
    convenience init(name: String, location: String?, type: String?, imageData:  Data?, rating: Double) {
        self.init()
        self.name = name
        self.type = type
        self.location = location
        self.imageData = imageData
        self.rating = rating
    }
//    let restaurantNames = [
//        "Burger Heroes", "Kitchen", "Bonsai", "Sherlock Holmes", "Speak Easy", "Morris Pub", "Love&Life"
//    ]
//
//    func savePlaces() {
//
//       // var places = [Place]()
//
//        for place in restaurantNames {
//
//            let image = UIImage(named: place)
//            guard let imageData = image?.pngData() else {return}
//
//            let newPlace = Place()
//            newPlace.name = place
//            newPlace.location = "USA"
//            newPlace.type = "Restaurant"
//            newPlace.imageData = imageData
//
//            StorageManager.saveObject(newPlace)
            
            //MARK: -default data with restaurants
//            places.append(Place(name: place, location: "Vancuuver", type: "Restaurant", image: nil, restaurantImage: place))
//        }
        
//        return places
//    }
}
