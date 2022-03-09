//
//  LocationDetailViewModel.swift
//  DubDubGrub
//
//  Created by Juan Diego Ocampo on 7/03/22.
//

import CloudKit
import MapKit
import SwiftUI

enum CheckInStatus { case checkedIn, checkedOut }

final class LocationDetailViewModel: ObservableObject {
    
    @Published var checkedInProfiles     : [DDGProfile] = []
    @Published var alertItem             : AlertItem?
    @Published var isShowingProfileModal = false
    @Published var isShowingProfileSheet = false
    @Published var isCheckedIn           = false
    @Published var isLoading             = false
    
    var location                         : DDGLocation
    var selectedProfile                  : DDGProfile?
    
    init(location: DDGLocation) { self.location = location }
    
    func determineColumns(for sizeCategory: ContentSizeCategory) -> [GridItem] {
        let numberOfColumns = sizeCategory >= .accessibilityMedium ? 1 : 3
        return Array(repeating: GridItem(.flexible()), count: numberOfColumns)
    }
    
    
    func getDirectionsToLocation() {
        let placemark   = MKPlacemark(coordinate: location.location.coordinate)
        let mapItem     = MKMapItem(placemark: placemark)
        mapItem.name    = location.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking])
    }
    
    
    func callLocation() {
        guard let url = URL(string: "tel://+1-\(location.phoneNumber)") else {
            alertItem = AlertContext.invalidPhoneURL
            return
        }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            alertItem = AlertContext.deviceCantMakeCalls
        }
    }
    
    
    func getCheckedInStatus() {
        guard let profileRecordID = CloudKitManager.shared.profileRecordID else { return }
        CloudKitManager.shared.fetchRecord(with: profileRecordID) { [self] result in
            DispatchQueue.main.async { [self] in
                switch result {
                case .success(let record):
                    if let reference = record[DDGProfile.kIsCheckedIn] as? CKRecord.Reference {
                        let currentStatus = reference.recordID == location.id
                        isCheckedIn = currentStatus
                        debugPrint(message: "⚠️ isCheckedIn == \(currentStatus) ⚠️")
                    } else {
                        isCheckedIn = false
                        debugPrint(message: "⚠️ isCheckedIn == false - REFERENCE  to \(location.name) IS nil ⚠️")
                    }
                case .failure(_):
                    alertItem = AlertContext.unableToGetCheckInStatus
                    debugPrint(message: "❌ ERROR FETCHING RECORD ❌")
                }
            }
        }
    }
    
    
    func updateCheckInStatus(to ckeckInStatus: CheckInStatus) {
        guard let profileRecordID = CloudKitManager.shared.profileRecordID else {
            alertItem = AlertContext.fetchingProfileError
            return
        }
        CloudKitManager.shared.fetchRecord(with: profileRecordID) { [self] result in
            switch result {
            case .success(let record):
                switch ckeckInStatus {
                case .checkedIn:
                    record[DDGProfile.kIsCheckedIn]         = CKRecord.Reference(recordID: location.id, action: .none)
                    record[DDGProfile.kIsCheckedInNilCheck] = 1
                    debugPrint(message: "✅ CHECKED INTO \(location.name) SUCCESSFULLY ✅")
                case .checkedOut:
                    record[DDGProfile.kIsCheckedIn]         = nil
                    record[DDGProfile.kIsCheckedInNilCheck] = nil
                    debugPrint(message: "✅ CHECKED OUT OF \(location.name) SUCCESSFULLY ✅")
                }
                CloudKitManager.shared.save(record: record) { [self] result in
                    DispatchQueue.main.async { [self] in
                        switch result {
                        case .success(_):
                            let profile = DDGProfile(record: record)
                            switch ckeckInStatus {
                            case .checkedIn:
                                checkedInProfiles.append(profile)
                                debugPrint(message: "✅ RECORD SAVED SUCCESSFULLY -- CHECK INTO \(location.name) ✅")
                            case .checkedOut:
                                checkedInProfiles.removeAll { $0.id == profile.id }
                                debugPrint(message: "✅ RECORD SAVED SUCCESSFULLY -- CHECK OUT OF \(location.name) ✅")
                            }
                            isCheckedIn = ckeckInStatus == .checkedIn
                        case .failure(_):
                            alertItem = AlertContext.unableToCheckInOrOut
                            debugPrint(message: "❌ ERROR SAVING RECORD ❌")
                        }
                    }
                }
            case .failure(_):
                alertItem = AlertContext.unableToCheckInOrOut
                debugPrint(message: "❌ ERROR FETCHING RECORD ❌")
            }
        }
    }
    
    func getChechedInProfiles() {
        showLoadingView()
        CloudKitManager.shared.getCheckedInProfiles(for: location.id) { [self] result in
            DispatchQueue.main.async { [self] in
                switch result {
                case .success(let profiles):
                    checkedInProfiles = profiles
                case .failure(_):
                    alertItem = AlertContext.unableToGetCheckedInProfiles
                    debugPrint(message: "❌ ERROR FETCHING CHECKED IN PROFILES ❌")
                }
                hideLoadingView()
            }
        }
    }
    
    
    func createVoiceOverSummary() -> String {
        let count = checkedInProfiles.count
        if count == 1 {
            return "Who's here? 1 person checked in"
        } else if count > 1 {
            return "Who's here? \(count) people checked in"
        } else {
            return "Who's here? Nobody's checked in"
        }
    }
    
    func show(profile: DDGProfile, in sizeCategory: ContentSizeCategory) {
        selectedProfile = profile
        if sizeCategory >= .accessibilityMedium {
            isShowingProfileSheet = true
        } else {
            isShowingProfileModal = true
        }
    }
    
    
    // MARK: - Helper Functions to Save or Dismiss LoadingView and Debug
    
    private func showLoadingView() { isLoading = true }
    private func hideLoadingView() { isLoading = false }
    private func debugPrint(message: String) { print(message) }
    
}
