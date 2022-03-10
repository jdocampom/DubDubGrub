//
//  ProfileViewModel.swift
//  DubDubGrub
//
//  Created by Juan Diego Ocampo on 5/03/22.
//

import CloudKit
import SwiftUI

enum ProfileContext { case create, update }

extension ProfileView {
    
    final class ProfileViewModel: ObservableObject {
        @Published var firstName            = ""
        @Published var lastName             = ""
        @Published var companyName          = ""
        @Published var bio                  = ""
        @Published var avatar               = PlaceholderImage.avatar
        @Published var isShowingPhotoPicker = false
        @Published var isLoading            = false
        @Published var isCheckedIn          = false
        @Published var alertItem: AlertItem?
        
        private var existingProfileRecord: CKRecord? {
            didSet { profileContext = .update }
        }
        
        var profileContext: ProfileContext = .create
        var buttonTitle: String { profileContext == .create ? "Create Profile" : "Update Profile" }
        
        
        private func isValidProfile() -> Bool {
            guard !firstName.isEmpty,
                  !lastName.isEmpty,
                  !companyName.isEmpty,
                  !bio.isEmpty,
                  avatar != PlaceholderImage.avatar,
                  bio.count <= 100 else { return false }
            
            return true
        }
        
        
        func getCheckedInStatus() {
            guard let profileRecordID = CloudKitManager.shared.profileRecordID else { return }
            
            CloudKitManager.shared.fetchRecord(with: profileRecordID) { [weak self] result in
                DispatchQueue.main.async { [weak self] in
                    switch result {
                    case .success(let record):
                        if let _ = record[DDGProfile.kIsCheckedIn] as? CKRecord.Reference {
                            self?.isCheckedIn = true
                        } else {
                            self?.isCheckedIn = false
                        }
                        
                    case .failure(_):
                        break
                    }
                }
            }
        }
        
        func checkOut() {
            guard let profileID = CloudKitManager.shared.profileRecordID else {
                HapticManager.playErrorHaptic()
                alertItem = AlertContext.fetchingProfileError
                return
            }
            
            showLoadingView()
            CloudKitManager.shared.fetchRecord(with: profileID) { result in
                
                switch result {
                case .success(let record):
                    record[DDGProfile.kIsCheckedIn] = nil
                    record[DDGProfile.kIsCheckedInNilCheck] = nil
                    
                    CloudKitManager.shared.save(record: record) { [weak self] result in
                        self?.self.hideLoadingView()
                        DispatchQueue.main.async { [weak self] in
                            switch result {
                            case .success(_):
                                HapticManager.playSuccessHaptic()
                                self?.isCheckedIn = false
                            case .failure(_):
                                HapticManager.playErrorHaptic()
                                self?.alertItem = AlertContext.unableToCheckInOrOut
                            }
                        }
                    }
                    
                case .failure(_):
                    
                    DispatchQueue.main.async {
                        self.hideLoadingView()
                        HapticManager.playErrorHaptic()
                        self.alertItem = AlertContext.unableToCheckInOrOut
                    }
                }
            }
        }
        
        
        func determineButtonAction() {
            profileContext == .create ? createProfile() : updateProfile()
        }
        
        
        private func createProfile() {
            guard isValidProfile() else {
                alertItem = AlertContext.invalidProfile
                return
            }
            
            let profileRecord = createProfileRecord()
            guard let userRecord = CloudKitManager.shared.userRecord else {
                alertItem = AlertContext.noUserRecord
                return
            }
            
            userRecord["userProfile"] = CKRecord.Reference(recordID: profileRecord.recordID, action: .none)
            
            showLoadingView()
            CloudKitManager.shared.batchSave(records: [userRecord, profileRecord]) { result in
                DispatchQueue.main.async { [weak self] in
                    self?.hideLoadingView()
                    
                    switch result {
                    case .success(let records):
                        for record in records where record.recordType == RecordType.profile {
                            self?.existingProfileRecord = record
                            CloudKitManager.shared.profileRecordID = record.recordID
                        }
                        self?.alertItem = AlertContext.createProfileSuccess
                        
                    case .failure(_):
                        HapticManager.playErrorHaptic()
                        self?.alertItem = AlertContext.createProfileError
                        break
                    }
                }
            }
        }
        
        
        func getProfile() {
            guard let userRecord = CloudKitManager.shared.userRecord else {
                alertItem = AlertContext.noUserRecord
                return
            }
            
            guard let profileReference = userRecord["userProfile"] as? CKRecord.Reference else { return }
            let profileRecordID = profileReference.recordID
            
            showLoadingView()
            CloudKitManager.shared.fetchRecord(with: profileRecordID) { result in
                DispatchQueue.main.async { [weak self] in
                    self?.hideLoadingView()
                    switch result {
                    case .success(let record):
                        self?.existingProfileRecord = record
                        
                        let profile = DDGProfile(record: record)
                        self?.firstName   = profile.firstName
                        self?.lastName    = profile.lastName
                        self?.companyName = profile.companyName
                        self?.bio         = profile.bio
                        self?.avatar      = profile.avatarImage
                        
                    case .failure(_):
                        HapticManager.playErrorHaptic()
                        self?.alertItem = AlertContext.fetchingProfileError
                        break
                    }
                }
            }
        }
        
        
        private func updateProfile() {
            guard isValidProfile() else {
                alertItem = AlertContext.invalidProfile
                return
            }
            
            guard let profileRecord = existingProfileRecord else {
                HapticManager.playErrorHaptic()
                alertItem = AlertContext.fetchingProfileError
                return
            }
            
            profileRecord[DDGProfile.kFirstName]    = firstName
            profileRecord[DDGProfile.kLastName]     = lastName
            profileRecord[DDGProfile.kCompanyName]  = companyName
            profileRecord[DDGProfile.kBio]          = bio
            profileRecord[DDGProfile.kAvatar]       = avatar.convertToCKAsset()
            
            showLoadingView()
            CloudKitManager.shared.save(record: profileRecord) { result in
                DispatchQueue.main.async { [weak self] in
                    self?.hideLoadingView()
                    switch result {
                    case .success(_):
//                        alertItem = AlertContext.updateProfileSuccess
                        break
                    case .failure(_):
                        HapticManager.playErrorHaptic()
                        self?.alertItem = AlertContext.updateProfileError
                    }
                }
            }
        }
        
        
        private func createProfileRecord() -> CKRecord {
            let profileRecord = CKRecord(recordType: RecordType.profile)
            profileRecord[DDGProfile.kFirstName]    = firstName
            profileRecord[DDGProfile.kLastName]     = lastName
            profileRecord[DDGProfile.kCompanyName]  = companyName
            profileRecord[DDGProfile.kBio]          = bio
            profileRecord[DDGProfile.kAvatar]       = avatar.convertToCKAsset()
            
            return profileRecord
        }
        
        
        private func showLoadingView() { isLoading = true }
        private func hideLoadingView() { isLoading = false }
    }
}


