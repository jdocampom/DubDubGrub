//
//  LocationMapViewModel.swift
//  DubDubGrub
//
//  Created by Juan Diego Ocampo on 4/03/22.
//

import CloudKit
import Foundation
import MapKit
import SwiftUI



extension LocationMapView {
    
    final class LocationMapViewModel: NSObject, ObservableObject {
        
        private static let mapConfiguration = (center: CLLocationCoordinate2D(latitude: 37.331516, longitude: -121.891054),
                                               span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        @Published var checkedInProfiles    : [CKRecord.ID: Int] = [:]
        @Published var alertItem            : AlertItem?
        @Published var isShowingDetailView  = false
        @Published var region               = MKCoordinateRegion(center: mapConfiguration.center, span: mapConfiguration.span)
        
        func getLocations(for locationManager: LocationManager) {
            CloudKitManager.shared.getLocations { [self] result in
                DispatchQueue.main.async { [self] in
                    switch result {
                    case .success(let locations):
                        locationManager.locations = locations
                    case .failure(_):
                        HapticManager.playErrorHaptic()
                        alertItem = AlertContext.unableToGetLocations
                    }
                }
            }
        }
        
        
        public func getCheckedInCount() {
            CloudKitManager.shared.getCheckedInProfilesCount { result in
                DispatchQueue.main.async { [self] in
                    switch result {
                    case .success(let checkedInProfiles):
                        self.checkedInProfiles = checkedInProfiles
                    case .failure(_):
                        HapticManager.playErrorHaptic()
                        alertItem = AlertContext.unableToGetCheckedInCount
                        break
                    }
                }
            }
        }
        
        public func createVoiceOverSummary(for location: DDGLocation) -> String {
            let count = checkedInProfiles[location.id, default: 0]
            if count == 1 {
                return "Map Pin: \(location.name) 1 person checked in."
            } else if count > 1 {
                return "Map Pin: \(location.name) \(count) people checked in."
            } else {
                return "Map Pin: \(location.name) Nobody's checked in."
            }
        }
        
        @ViewBuilder public func createLocationDetailView(for location: DDGLocation, in sizeCategory: ContentSizeCategory) -> some View {
            if sizeCategory >= .accessibilityMedium {
                LocationDetailView(viewModel: LocationDetailViewModel(location: location)).embedInScrollView()
            } else {
                LocationDetailView(viewModel: LocationDetailViewModel(location: location))
            }
        }
        
    }
    
}
