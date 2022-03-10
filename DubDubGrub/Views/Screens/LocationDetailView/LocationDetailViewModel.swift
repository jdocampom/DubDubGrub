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
    
    var buttonColor: Color { isCheckedIn ? .grubRed : .brandPrimary }
    var buttonLabel: String { isCheckedIn ? "person.fill.xmark" : "person.fill.checkmark" }
    var accesibilityLabel: String { isCheckedIn ? "Check out" : "Check in" }
    
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
        CloudKitManager.shared.fetchRecord(with: profileRecordID) { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success(let record):
                    if let reference = record[DDGProfile.kIsCheckedIn] as? CKRecord.Reference {
                        let currentStatus = reference.recordID == self?.location.id
                        self?.isCheckedIn = currentStatus
                        self?.debugPrint(message: "⚠️ isCheckedIn == \(currentStatus) ⚠️")
                    } else {
                        self?.isCheckedIn = false
                        self?.debugPrint(message: "⚠️ isCheckedIn == false - REFERENCE  to \(String(describing: self?.location.name)) IS nil ⚠️")
                    }
                case .failure(_):
                    HapticManager.playErrorHaptic()
                    self?.alertItem = AlertContext.unableToGetCheckInStatus
                    self?.debugPrint(message: "❌ ERROR FETCHING RECORD ❌")
                }
            }
        }
    }
    
    
    func updateCheckInStatus(to ckeckInStatus: CheckInStatus) {
        guard let profileRecordID = CloudKitManager.shared.profileRecordID else {
            alertItem = AlertContext.fetchingProfileError
            return
        }
        showLoadingView()
        CloudKitManager.shared.fetchRecord(with: profileRecordID) { [weak self] result in
            switch result {
            case .success(let record):
                switch ckeckInStatus {
                case .checkedIn:
                    record[DDGProfile.kIsCheckedIn]         = CKRecord.Reference(recordID: (self?.location.id)!, action: .none)
                    record[DDGProfile.kIsCheckedInNilCheck] = 1
                    self?.debugPrint(message: "✅ CHECKED INTO \(String(describing: self?.location.name)) SUCCESSFULLY ✅")
                case .checkedOut:
                    record[DDGProfile.kIsCheckedIn]         = nil
                    record[DDGProfile.kIsCheckedInNilCheck] = nil
                    self?.debugPrint(message: "✅ CHECKED OUT OF \(String(describing: self?.location.name)) SUCCESSFULLY ✅")
                }
                CloudKitManager.shared.save(record: record) { [weak self] result in
                    DispatchQueue.main.async { [weak self] in
                        self?.hideLoadingView()
                        switch result {
                        case .success(_):
                            HapticManager.playSuccessHaptic()
                            let profile = DDGProfile(record: record)
                            switch ckeckInStatus {
                            case .checkedIn:
                                self?.checkedInProfiles.append(profile)
                                self?.debugPrint(message: "✅ RECORD SAVED SUCCESSFULLY -- CHECK INTO \(String(describing: self?.location.name))✅")
                            case .checkedOut:
                                self?.checkedInProfiles.removeAll { $0.id == profile.id }
                                self?.debugPrint(message: "✅ RECORD SAVED SUCCESSFULLY -- CHECK OUT OF \(String(describing: self?.location.name) )✅")
                            }
                            self?.isCheckedIn.toggle()
                        case .failure(_):
                            HapticManager.playErrorHaptic()
                            self?.alertItem = AlertContext.unableToCheckInOrOut
                            self?.debugPrint(message: "❌ ERROR SAVING RECORD ❌")
                        }
                    }
                }
            case .failure(_):
                self?.hideLoadingView()
                HapticManager.playErrorHaptic()
                self?.alertItem = AlertContext.unableToCheckInOrOut
                self?.debugPrint(message: "❌ ERROR FETCHING RECORD ❌")
            }
        }
    }
    
    func getChechedInProfiles() {
        showLoadingView()
        CloudKitManager.shared.getCheckedInProfiles(for: location.id) { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success(let profiles):
                    self?.checkedInProfiles = profiles
                case .failure(_):
                    HapticManager.playErrorHaptic()
                    self?.alertItem = AlertContext.unableToGetCheckedInProfiles
                    self?.debugPrint(message: "❌ ERROR FETCHING CHECKED IN PROFILES ❌")
                }
                self?.hideLoadingView()
            }
        }
    }
    
    
    func createVoiceOverSummary() -> String {
        let count = checkedInProfiles.count
        if count == 1 {
            return "Who's here? 1 person checked in."
        } else if count > 1 {
            return "Who's here? \(count) people checked in."
        } else {
            return "Who's here? Nobody's checked in yet."
        }
    }
    
    func show(_ profile: DDGProfile, in sizeCategory: ContentSizeCategory) {
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
