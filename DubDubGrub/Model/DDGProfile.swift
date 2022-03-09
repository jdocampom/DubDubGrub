//
//  DDGProfile.swift
//  DubDubGrub
//
//  Created by Juan Diego Ocampo on 3/03/22.
//

import CloudKit
import UIKit

struct DDGProfile: Identifiable {
    
    static let kAvatar              = "avatar"
    static let kBio                 = "bio"
    static let kCompanyName         = "companyName"
    static let kFirstName           = "firstName"
    static let kIsCheckedIn         = "isCheckedIn"
    static let kLastName            = "lastName"
    static let kIsCheckedInNilCheck = "isCheckedInNilCheck"
    
    
    let id          : CKRecord.ID
    let avatar      : CKAsset!
    let bio         : String
    let companyName : String
    let firstName   : String
//    let isCheckedIn : CKRecord.Reference?
    let lastName    : String
    
    var avatarImage: UIImage {
        guard let avatar = avatar else { return PlaceholderImage.avatar }
        return avatar.convertToUIImage(in: .square)
    }
    
    
    init(record: CKRecord) {
        id          = record.recordID
        avatar      = record[DDGProfile.kAvatar]        as? CKAsset
        bio         = record[DDGProfile.kBio]           as? String ?? "N/A"
        companyName = record[DDGProfile.kCompanyName]   as? String ?? "N/A"
        firstName   = record[DDGProfile.kFirstName]     as? String ?? "N/A"
        lastName    = record[DDGProfile.kLastName]      as? String ?? "N/A"
//        isCheckedIn = record[DDGProfile.kIsCheckedIn]   as? CKRecord.Reference
    }
    
}
