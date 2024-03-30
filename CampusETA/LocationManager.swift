//
//  LocationManager.swift
//  CampusETA
//
//  Created by Keshav Varadarajan on 3/30/24.
//

import CoreLocation


class LocationManager : NSObject, ObservableObject {
    private let manager = CLLocationManager()
    @Published var userLocation : CLLocation?
    
    static let shared = LocationManager()
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.startUpdatingLocation()
    }
    
    
    func requestLocation() {
        manager.requestWhenInUseAuthorization()
    }
}

extension LocationManager : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch (status) {
            
        case .notDetermined:
            print("DEBUG: Not determined")
        case .restricted:
            print("DEBUG: Access Restricted")
        case .denied:
            print("DEBUG: Access Denied")
        case .authorizedAlways:
            print("DEBUG: Access Authorized Always")
        case .authorizedWhenInUse:
            print("DEBUG: Access Authorized When In Use")
        @unknown default:
            break
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return}
        
        self.userLocation = location
    }
}


