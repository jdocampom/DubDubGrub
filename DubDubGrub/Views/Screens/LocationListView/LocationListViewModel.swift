//
//  LocationListViewModel.swift
//  DubDubGrub
//
//  Created by Juan Diego Ocampo on 8/03/22.
//

import CloudKit
import SwiftUI

final class LocationListViewModel: ObservableObject {
    
    @Published var checkedInProfiles: [CKRecord.ID : [DDGProfile]] = [:]
    
    func getCheckedInProfilesDictionary() {
        CloudKitManager.shared.getCheckedInProfilesDictionary { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let checkedInProfiles):
                    self.checkedInProfiles = checkedInProfiles
                case .failure(_):
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
    
}