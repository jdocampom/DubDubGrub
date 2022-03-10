//
//  LocationListViewModel.swift
//  DubDubGrub
//
//  Created by Juan Diego Ocampo on 8/03/22.
//

import CloudKit
import SwiftUI

extension LocationListView {
    
    final class LocationListViewModel: ObservableObject {
        
        @Published var checkedInProfiles: [CKRecord.ID : [DDGProfile]] = [:]
        @Published var alertItem: AlertItem?
        
        func getCheckedInProfilesDictionary() {
            CloudKitManager.shared.getCheckedInProfilesDictionary { result in
                DispatchQueue.main.async { [weak self] in
                    switch result {
                    case .success(let checkedInProfiles):
                        self?.checkedInProfiles = checkedInProfiles
                        print("✅ SUCCESS FETCHING checkedInProfiles DICTIONARY -- LocationListViewModel ✅")
                    case .failure(_):
                        HapticManager.playErrorHaptic()
                        self?.alertItem = AlertContext.unableToGetAllCheckedInProfiles
                        print("❌ ERROR RETRIEVING checkedInProfiles DICTIONARY -- LocationListViewModel ❌")
                    }
                }
            }
        }
        
        
        func createVoiceOverSummary(for location: DDGLocation) -> String {
            let count = checkedInProfiles[location.id, default: []].count
            if count == 1 {
                return "\(location.name) 1 person checked in"
            } else if count > 1 {
                return "\(location.name) \(count) people checked in"
            } else {
                return "\(location.name) Nobody's checked in"
            }
        }
        
        @ViewBuilder func createLocationDetailView(for location: DDGLocation, in sizeCategory: ContentSizeCategory) -> some View {
            if sizeCategory >= .accessibilityMedium {
                LocationDetailView(viewModel: LocationDetailViewModel(location: location)).embedInScrollView()
            } else {
                LocationDetailView(viewModel: LocationDetailViewModel(location: location))
            }
        }
        
    }
    
}
