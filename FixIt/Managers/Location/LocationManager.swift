//
//  LocationManager.swift
//  FixIt
//
//  Created by Josiah Agosto on 6/5/20.
//  Copyright © 2020 Josiah Agosto. All rights reserved.
//

import UIKit
import CoreLocation

// TODO: User Location isn't being written to when changing location.
class LocationManager: NSObject, CLLocationManagerDelegate {
    // Properties / References
    static let shared = LocationManager()
    public var locationManager: CLLocationManager
    private let locationHelper = LocationHelperClass()
    private var profileDataModel: ProfileDataModel?
    public var userLocation: String = ""
    private weak var errorControllerDelegate: ErrorControllerProtocol?
    
    override init() {
        locationManager = CLLocationManager()
        super.init()
        locationManager.delegate = self
        locationSetup()
    }
    
    
    deinit {
        stopLocating()
    }
    
    
    public func locationSetup() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestLocation()
    }
    
    
    public func startLocating() {
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.distanceFilter = 100.0
        locationManager.pausesLocationUpdatesAutomatically = true
    }
    
    
    public func stopLocating() {
        locationManager.stopUpdatingLocation()
        locationManager.stopMonitoringSignificantLocationChanges()
    }
    
    
    public func reverseUserLocationToAddress(from longitude: CLLocationDegrees, and latitude: CLLocationDegrees, completion: @escaping(String) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(CLLocation(latitude: latitude, longitude: longitude)) { (place, error) in
            if let error = error {
                print("Reverse Geocode Error: \(error.localizedDescription)")
            }
            if let place = place {
                guard let address = place.first?.name else { return }
                guard let city = place.first?.subLocality else { return }
                guard let state = place.first?.locality else { return }
                let fullAddress = "\(address), \(city), \(state)"
                print("String: \(fullAddress)")
                completion(fullAddress)
            }
        }
    }
    
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if #available(iOS 14.0, *) {
            switch manager.authorizationStatus {
                case .notDetermined:
                    print("Not determined")
                    return
                case .restricted:
                    self.errorControllerDelegate?.locationErrorController(with: "FixIt requires location", and: "Seems like we couldn't access your location. To do so go to Settings.")
                case .denied:
                    self.errorControllerDelegate?.locationErrorController(with: "FixIt requires location", and: "Seems like we couldn't access your location. To do so go to Settings.")
                case .authorizedAlways:
                    startLocating()
                case .authorizedWhenInUse:
                    startLocating()
                @unknown default:
                    startLocating()
            }
        } else {
            print("Pre iOS 14.")
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        var userLocation = ""
        let group = DispatchGroup()
        group.enter()
        reverseUserLocationToAddress(from: location.coordinate.longitude, and: location.coordinate.latitude) { (locationString) in
            userLocation = locationString
            group.leave()
        }
        group.notify(queue: .main) {
            self.userLocation = userLocation
            self.profileDataModel?.addUserData(to: .location, with: userLocation)
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.errorControllerDelegate?.locationErrorController(with: "Location Failed", and: error.localizedDescription)
    }
}