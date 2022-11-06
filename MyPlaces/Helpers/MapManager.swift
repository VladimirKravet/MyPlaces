//
//  MapManager.swift
//  MyPlaces
//
//  Created by Vladimir Kravets on 05.11.2022.
//

import UIKit
import MapKit

class MapManager {
    
    let locationManager = CLLocationManager()
    
    private let regionInMeters = 1000.00
    private var directionsArray: [MKDirections] = []
    private var distanceLocationFromUser = 50.00
    private var placeCoordinate: CLLocationCoordinate2D?
    var infoText : String?
    
    
    //MARK: - marker of a place
    func setupPlacemark(place: Place, mapView: MKMapView ) {
        
        guard let location = place.location else { return }
        // // change address to coordinate
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { (placemarks, error) in
            if let error = error {
                print(error)
            }
            guard let placemarks = placemarks else {return}
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation()
            annotation.title = place.name
            annotation.title = place.type
            
            guard let placemarkLocation = placemark?.location else {return}
            annotation.coordinate = placemarkLocation.coordinate
            
            self.placeCoordinate = placemarkLocation.coordinate
            
            mapView.showAnnotations([annotation], animated: true)
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
    //MARK: -cheack availability geolocation service
    
    func checkLocationServices(mapView: MKMapView, segueIdentifier: String, closure: () -> ()) {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationAutorization(mapView: mapView, segueIdentifier: segueIdentifier)
            closure()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Location Services are Disabled", message: "To enable it go: Settings -> Privacy -> Location Services and turn On")
            }
        }
    }
    
    //MARK: check app autorization for use geolocation services
    func checkLocationAutorization(mapView: MKMapView, segueIdentifier: String) {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if segueIdentifier == "getAddress" {showUserLocation(mapView: mapView)}
            break
        case .denied:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Your location is not Avalieble", message: "To enable it go: Settings -> MyPlace -> Location")
            }
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .authorizedAlways:
            break
            
        @unknown default:
            print("New case is available")
        }
    }
    //MARK: -map focuse on user location
    func showUserLocation(mapView: MKMapView) {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
            print("pressed")
        }
    }
    //MARK: -route from user to the place
    func getDirections(for mapView: MKMapView, previosLocation: (CLLocation) -> ()) {
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Current locatin is not found")
            return
        }
        
        locationManager.startUpdatingLocation()
        previosLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
        
        
        guard let request = creatDirectionsRequest(from: location) else {
            showAlert(title: "Error", message: "Destination is not found")
            return}
        
        let directions = MKDirections(request: request)
        resetpMapView(withNew: directions,mapView: mapView)
        directions.calculate { response, error in
            if let error = error {
                print(error)
            }
            guard let responce = response else {
                self.showAlert(title: "Error", message: "Directions is not available")
                return
                
            }
            for route in responce.routes {
                mapView.addOverlay(route.polyline)
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                let distance = String(format: "%.1f", route.distance / 1000)
                let timeInterval: TimeInterval = route.expectedTravelTime
                guard let timeInterval = timeInterval.toString(precision: .minutes) else {return}
                
                self.infoText = ("Distance is: \(distance) km and deliver time: \(timeInterval)")
                
            }
        }
    }
    
    //MARK: -setting up a request for route calculation
    func creatDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        
        guard let destinationCoordinate = placeCoordinate else {return nil}
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        return request
    }
    //MARK: - tracking user location
    func startTrackingUserLocation(for mapView: MKMapView, and location: CLLocation?, clouser: (_ currentLocation: CLLocation) -> ()) {
        
        //        guard let previosLocation = previosLocation else {
        //            return
        //        }
        guard let location = location else {
            return
        }
        
        let center = getCenterLocation(for: mapView)
        guard center.distance(from: location) > distanceLocationFromUser else {return}
        clouser(center)
        
        //        self.previosLocation = center
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
        //            self.showUserLocation()
        //
        //        }
    }
    //MARK: - reset route
    func resetpMapView(withNew directions: MKDirections, mapView: MKMapView) {
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map {$0.cancel() }
        directionsArray.removeAll()
    }
    //MARK: - get center
    func getCenterLocation(for mapView: MKMapView) ->CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert, animated: true)
        
   
    }
}

extension TimeInterval {
    
    enum Precision {
        case hours, minutes, seconds, milliseconds
    }
    
    func toString(precision: Precision) -> String? {
        guard self > 0 && self < Double.infinity else {
            assertionFailure("wrong value")
            return nil
        }
        
        let time = NSInteger(self)
        
        let ms = Int((self.truncatingRemainder(dividingBy: 1)) * 1000)
        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)
        
        switch precision {
        case .hours:
            return String(format: "%0.2d", hours)
        case .minutes:
            return String(format: "%0.2d:%0.2d", hours, minutes)
        case .seconds:
            return String(format: "%0.2d:%0.2d:%0.2d", hours, minutes, seconds)
        case .milliseconds:
            return String(format: "%0.2d:%0.2d:%0.2d.%0.3d", hours, minutes, seconds, ms)
        }
    }
}
