//
//  ProfileViewModel.swift
//  DubDubGrub
//
//  Created by Juan Diego Ocampo on 5/03/22.
//

import CloudKit

enum ProfileContext { case create, update }

final class ProfileViewModel: ObservableObject {
    
    @Published var firstName                = ""
    @Published var lastName                 = ""
    @Published var company                  = ""
    @Published var bio                      = ""
    @Published var avatar                   = PlaceholderImage.avatar
    @Published var isShowingPhotoPicker     = false
    @Published var isLoading                = false
    @Published var alertItem                : AlertItem?
    @Published var isCheckedIn              = false
    
    var profileContext: ProfileContext      = .create
    private var existingProfileRecord       : CKRecord? {
        didSet { profileContext = .update }
    }

    
    private func isValidProfile() -> Bool {
        guard !firstName.isEmpty,
              !lastName.isEmpty,
              !company.isEmpty,
              !bio.isEmpty,
              avatar != PlaceholderImage.avatar,
              bio.count <= 100 else { return false }
        return true
    }
    
    // MARK: - Create User Profile
    
    func createProfile() {
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
            DispatchQueue.main.async { [self] in
                hideLoadingView()
                switch result {
                case .success(let records):
                    for record in records where record.recordType == RecordType.profile {
                        existingProfileRecord = record
                        CloudKitManager.shared.profileRecordID = record.recordID
                    }
                    alertItem = AlertContext.createProfileSuccess
                    break
                case .failure(_):
                    alertItem = AlertContext.createProfileError
                    break
                }
            }
        }
    }
    
    // MARK: - Fetch User Profile
    
    func getProfile() {
        guard let userRecord = CloudKitManager.shared.userRecord else { alertItem = AlertContext.noUserRecord; return }
        guard let profileReference = userRecord["userProfile"] as? CKRecord.Reference else { return }
        let profileRecordID = profileReference.recordID
        showLoadingView()
        CloudKitManager.shared.fetchRecord(with: profileRecordID) { result in
            DispatchQueue.main.async { [self] in
                hideLoadingView()
                switch result {
                case .success(let record):
                    existingProfileRecord   = record
                    let profile             = DDGProfile(record: record)
                    firstName               = profile.firstName
                    lastName                = profile.lastName
                    company                 = profile.companyName
                    bio                     = profile.bio
                    avatar                  = profile.createAvatarImage()
                case .failure(_):
                    alertItem = AlertContext.fetchingProfileError
                    break
                }
            }
        }
    }
    
    // MARK: - Update User Profile
    
    func updateProfile() {
        guard isValidProfile() else {
            alertItem = AlertContext.invalidProfile
            return
        }
        guard let profileRecord = existingProfileRecord else {
            alertItem = AlertContext.fetchingProfileError
            return
        }
        profileRecord[DDGProfile.kFirstName]    = firstName
        profileRecord[DDGProfile.kLastName]     = lastName
        profileRecord[DDGProfile.kCompanyName]  = company
        profileRecord[DDGProfile.kBio]          = bio
        profileRecord[DDGProfile.kAvatar]       = avatar.convertToCKAsset()
        showLoadingView()
        CloudKitManager.shared.save(record: profileRecord) { result in
            DispatchQueue.main.async { [self] in
                hideLoadingView()
                switch result {
                case .success(_):
                    alertItem = AlertContext.updateProfileSuccess
                    break
                case .failure(_):
                    alertItem = AlertContext.updateProfileError
                    break
                }
            }
        }
    }
    
    
    func getCheckedInStatus() {
        guard let profileRecordID = CloudKitManager.shared.profileRecordID else { return }
        CloudKitManager.shared.fetchRecord(with: profileRecordID) { [self] result in
            DispatchQueue.main.async { [self] in
                switch result {
                case .success(let record):
                    if let _ = record[DDGProfile.kIsCheckedIn] as? CKRecord.Reference {
                        isCheckedIn = true
                    } else {
                        isCheckedIn = false
                    }
                case .failure(_):
                    break
                }
            }
        }
    }
    
    
    func checkOut() {
        guard let profileID = CloudKitManager.shared.profileRecordID else {
            alertItem = AlertContext.fetchingProfileError
            return
        }
        
        CloudKitManager.shared.fetchRecord(with: profileID) { result in
            switch result {
                case .success(let record):
                    record[DDGProfile.kIsCheckedIn] = nil
                    record[DDGProfile.kIsCheckedInNilCheck] = nil
                    CloudKitManager.shared.save(record: record) { [self] result in
                        DispatchQueue.main.async { [self] in
                            switch result {
                                case .success(_):
                                    isCheckedIn = false
                                case .failure(_):
                                    alertItem = AlertContext.unableToCheckInOrOut
                            }
                        }
                    }
                    
                case .failure(_):
                    DispatchQueue.main.async { self.alertItem = AlertContext.unableToCheckInOrOut }
            }
        }
    }
    
    // MARK: - Create Profile Record in CloudKit
    
    private func createProfileRecord() -> CKRecord {
        let profileRecord = CKRecord(recordType: RecordType.profile)
        profileRecord[DDGProfile.kFirstName]    = firstName
        profileRecord[DDGProfile.kLastName]     = lastName
        profileRecord[DDGProfile.kCompanyName]  = company
        profileRecord[DDGProfile.kBio]          = bio
        profileRecord[DDGProfile.kAvatar]       = avatar.convertToCKAsset()
        return profileRecord
    }
    
    // MARK: - Helper Functions to Save or Dismiss LoadingView
    
    private func showLoadingView() { isLoading = true }
    private func hideLoadingView() { isLoading = false }
    
}
