//
//  MapManager.swift
//  My Places
//
//  Created by kris on 14/06/2020.
//  Copyright © 2020 kris. All rights reserved.
//

import UIKit
import MapKit

class MapManager {
    
    let locationManager = CLLocationManager()
    
    private let regionInMeters = 1000.00
    private var placeCoordinate: CLLocationCoordinate2D?
    private var directionsArray: [MKDirections] = []
    
    
    func setupPlaceMark(place: Place, mapView: MKMapView) {
        
        guard let location = place.location else {return}
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { (placemarks, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            guard let placemarks = placemarks else {return}
            
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation()
            annotation.title = place.name
            annotation.subtitle = place.type
            
            guard let placemarkLocation = placemark?.location else {return}
            
            annotation.coordinate = placemarkLocation.coordinate
            self.placeCoordinate = placemarkLocation.coordinate
            
            mapView.selectAnnotation(annotation, animated: true)
            mapView.showAnnotations([annotation], animated: true)
        }
    }
    
    // Определяем доступность сервисов геолокации
    func checkLocationServices(mapView: MKMapView, segueIdentifier: String, closure: () -> ()) {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationAuthorization(mapView: mapView, segueIdentifier: segueIdentifier)
            closure()
            } else {
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                self.showAlert(title: "Your location is not avaliable",
                               message: "To give permission go to: Settings -> My Places -> location")
            }
        }
    }
    
    func checkLocationAuthorization(mapView: MKMapView, segueIdentifier: String) {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            if segueIdentifier == "getAdress" {showUserLocation(mapView: mapView)}
            mapView.showsUserLocation = true
            break
        case .denied:
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                self.showAlert(title: "Your location is not avaliable",
                               message: "To give permission go to: Settings -> My Places -> location")
            }
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .authorizedAlways:
            break
        case .restricted:
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                self.showAlert(title: "Your location is not avaliable",
                               message: "To give permission go to: Settings -> My Places -> location")
            }
            break
        }
    }
    
    func showUserLocation(mapView: MKMapView) {
        if let location = locationManager.location?.coordinate {
                   let region = MKCoordinateRegion.init(center: location,
                                                        latitudinalMeters: regionInMeters,
                                                        longitudinalMeters: regionInMeters)
                   mapView.setRegion(region, animated: true)
        }
    }
    
    func getDirectios(for mapView: MKMapView, previousLocation: (CLLocation) -> ()) {
           
           guard let location = locationManager.location?.coordinate else {
               showAlert(title: "Error", message: "Location coordinate is not found")
               return
           }
           
           locationManager.startUpdatingLocation()
           previousLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
        
           guard let request = createDirectionsReqest(from: location) else {
               showAlert(title: "Error", message: "Direction is not found")
               return
           }
           
           let direction = MKDirections(request: request)
           resetMapView(withNew: direction, mapView: mapView)
           
           direction.calculate { (response, error) in
               
               if let error = error {
                   print(error)
                   return
               }
               
               guard let response = response else {
                   self.showAlert(title: "Error", message: "Direction is not available")
                   return
               }
               
               for route in response.routes {
                   mapView.addOverlay(route.polyline)
                   mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                   
                   let distance = String(format: "%.1f", route.distance)
                   let timeInterval = route.expectedTravelTime
                   
                   print("Расстояние до места - \(distance) км")
                   print("Время в пути - \(timeInterval) сек")
               }
           }
       }
    
    func createDirectionsReqest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        
        guard let destanationCoordinate = placeCoordinate else {return nil}
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destanationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        
        return request
    }
    
    // Меняем отображаемую зону области карты в соответствии с перемешением пользователя
    func startTrackingUserLocation(for mapView: MKMapView, and location: CLLocation?, closure: (_ currentLocation: CLLocation) -> ()) {
        
        guard let location = location else {return}
        let center = getCenterLocation(for: mapView)
        guard center.distance(from: location) > 50 else {return}
        
        closure(center)
    }
    
    // Сброс всех ранее построенных маршрутов перед построением нового
    func resetMapView(withNew directions: MKDirections, mapView: MKMapView) {
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel() }
        directionsArray.removeAll()
    }
    
    // Определение центра отображаемой области карты
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
           
           let latitude = mapView.centerCoordinate.latitude
           let longitude = mapView.centerCoordinate.longitude
           
           return CLLocation(latitude: latitude, longitude: longitude)
       }
       
    
    func showAlert(title: String, message: String) {
           
           let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
           let okAction = UIAlertAction(title: "Ok", style: .default)
           
           alert.addAction(okAction)
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert+1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert, animated: true)
       }
}
