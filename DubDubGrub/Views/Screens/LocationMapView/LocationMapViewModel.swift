//
//  LocationMapViewModel.swift
//  DubDubGrub
//
//  Created by Juan Diego Ocampo on 4/03/22.
//

import CloudKit
import Foundation
import MapKit

final class LocationMapViewModel: NSObject, ObservableObject {
    
    @Published var checkedInProfiles: [CKRecord.ID: Int] = [:]
    @Published var alertItem    : AlertItem?
    @Published var isShowingDetailView    = false
    @Published var region       = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.331516, longitude: -121.891054),
                                                     span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    
    func getLocations(for locationManager: LocationManager) {
        CloudKitManager.shared.getLocations { [self] result in
            DispatchQueue.main.async { [self] in
                switch result {
                case .success(let locations):
                    locationManager.locations = locations
                case .failure(_):
                    alertItem = AlertContext.unableToGetLocations
                }
            }
        }
    }
    
    
    func getCheckedInCount() {
        CloudKitManager.shared.getCheckedInProfilesCount { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let checkedInProfiles):
                    self.checkedInProfiles = checkedInProfiles
                case .failure(_):
                    // alert
                    break
                }
            }
        }
    }
    
    func createVoiceOverSummary(for location: DDGLocation) -> String {
        let count = checkedInProfiles[location.id, default: 0]
        if count == 1 {
            return "\(location.name) 1 person checked in"
        } else if count > 1 {
            return "\(location.name) \(count) people checked in"
        } else {
            return "\(location.name) Nobody's checked in"
        }
    }
    
}
