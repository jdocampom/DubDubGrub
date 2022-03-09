//
//  MockData.swift
//  DubDubGrub
//
//  Created by Juan Diego Ocampo on 3/03/22.
//

import CloudKit

struct MockData {
    
    static var location: CKRecord {
        let record                          = CKRecord(recordType: RecordType.location)
        record[DDGLocation.kName]           = "Sean's Bar & Grill"
        record[DDGLocation.kAddress]        = "123 Main Street"
        record[DDGLocation.kDescription]    = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam nec quam eros."
        record[DDGLocation.kWebsiteURL]     = "https://www.apple.com"
        record[DDGLocation.kLocation]       = CLLocation(latitude: 37.331516, longitude: -121.891054)
        record[DDGLocation.kPhoneNumber]    = "316-741-6031"
        return record
    }
    
    static var profile: CKRecord {
        let record                          = CKRecord(recordType: RecordType.profile)
        record[DDGProfile.kFirstName]       = "Sean"
        record[DDGProfile.kLastName]        = "Allen"
        record[DDGProfile.kCompanyName]     = "Creator View"
        record[DDGProfile.kBio]             = "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
        return record
    }
    
}
