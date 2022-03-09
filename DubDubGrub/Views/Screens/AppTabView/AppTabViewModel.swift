//
//  AppTabViewModel.swift
//  DubDubGrub
//
//  Created by Juan Diego Ocampo on 8/03/22.
//

import CoreLocation
import SwiftUI

extension AppTabView {
    
    final class AppTabViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
        
        @Published var isShowingOnboardingView = false
        @Published var alertItem               : AlertItem?
        @AppStorage("hasSeenOnboardView") var hasSeenOnboardView = false {
            didSet {
                isShowingOnboardingView = hasSeenOnboardView
            }
        }
        
        
        var deviceLocationManager   : CLLocationManager?
        
        
        func runStartupChecks() {
            if !hasSeenOnboardView {
                hasSeenOnboardView = true
            } else {
                ckeckIfLocationServicesIsEnabled()
            }
        }
        
        
        func ckeckIfLocationServicesIsEnabled() {
            if CLLocationManager.locationServicesEnabled() {
                deviceLocationManager            = CLLocationManager()
                deviceLocationManager!.delegate  = self
            } else {
                HapticManager.playErrorHaptic()
                alertItem = AlertContext.locationDisabled
            }
        }
        
        func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            checkLocationAuthorisation()
        }
        
        private func checkLocationAuthorisation() {
            guard let deviceLocationManager = deviceLocationManager else { return }
            switch deviceLocationManager.authorizationStatus {
            case .notDetermined:
                deviceLocationManager.requestWhenInUseAuthorization()
            case .restricted:
                HapticManager.playErrorHaptic()
                alertItem = AlertContext.locationRestricted
            case .denied:
                HapticManager.playErrorHaptic()
                alertItem = AlertContext.locationDenied
            case .authorizedAlways, .authorizedWhenInUse:
                break
            @unknown default:
                break
            }
        }
        
    }
    
}
