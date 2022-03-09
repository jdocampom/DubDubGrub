//
//  AppTabViewModel.swift
//  DubDubGrub
//
//  Created by Juan Diego Ocampo on 8/03/22.
//

import CoreLocation

final class AppTabViewModel: NSObject, ObservableObject {
    
    @Published var isShowingOnboardingView = false
    @Published var alertItem               : AlertItem?
    
    let kHasSeenOnboardView     = "hasSeenOnboardView"
    
    var deviceLocationManager   : CLLocationManager?
    var hasSeenOnboardView      : Bool { return UserDefaults.standard.bool(forKey: kHasSeenOnboardView) }
    
    
    func runStartupChecks() {
        if !hasSeenOnboardView {
            isShowingOnboardingView = true
            UserDefaults.standard.set(true, forKey: kHasSeenOnboardView)
        } else {
            ckeckIfLocationServicesIsEnabled()
        }
    }
    
    
    func ckeckIfLocationServicesIsEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            deviceLocationManager            = CLLocationManager()
            deviceLocationManager!.delegate  = self
        } else {
            // Show Alert
            alertItem = AlertContext.locationDisabled
        }
    }
    
    
    private func checkLocationAuthorisation() {
        guard let deviceLocationManager = deviceLocationManager else { return }
        switch deviceLocationManager.authorizationStatus {
        case .notDetermined:
            deviceLocationManager.requestWhenInUseAuthorization()
        case .restricted:
            alertItem = AlertContext.locationRestricted
        case .denied:
            alertItem = AlertContext.locationDenied
        case .authorizedAlways, .authorizedWhenInUse:
            break
        @unknown default:
            break
        }
    }
    
}

extension AppTabViewModel: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorisation()
    }
}
