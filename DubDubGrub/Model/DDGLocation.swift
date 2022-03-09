//
//  DDGLocation.swift
//  DubDubGrub
//
//  Created by Juan Diego Ocampo on 3/03/22.
//

import CloudKit
import UIKit

struct DDGLocation: Identifiable {
    
    static let kAddress         = "address"
    static let kBannerAsset     = "bannerAsset"
    static let kDescription     = "description"
    static let kLocation        = "location"
    static let kName            = "name"
    static let kPhoneNumber     = "phoneNumber"
    static let kSquareAsset     = "squareAsset"
    static let kWebsiteURL      = "websiteURL"
    
    
    let id          : CKRecord.ID
    let address     : String
    let bannerAsset : CKAsset!
    let description : String
    let location    : CLLocation
    let name        : String
    let phoneNumber : String
    let squareAsset : CKAsset!
    let websiteURL  : String
    
    var squareImage: UIImage {
        guard let asset = squareAsset else { return PlaceholderImage.square }
        return asset.convertToUIImage(in: .square)
        
        
    }
    
    var bannerImage: UIImage {
        guard let asset = bannerAsset else { return PlaceholderImage.banner }
        return asset.convertToUIImage(in: .banner)
    }
    
    init(record: CKRecord) {
        id          = record.recordID
        address     = record[DDGLocation.kAddress]      as? String ?? "N/A"
        bannerAsset = record[DDGLocation.kBannerAsset]  as? CKAsset
        description = record[DDGLocation.kDescription]  as? String ?? "N/A"
        location    = record[DDGLocation.kLocation]     as? CLLocation ?? CLLocation(latitude: 0, longitude: 0)
        name        = record[DDGLocation.kName]         as? String ?? "N/A"
        phoneNumber = record[DDGLocation.kPhoneNumber]  as? String ?? "N/A"
        squareAsset = record[DDGLocation.kSquareAsset]  as? CKAsset
        websiteURL  = record[DDGLocation.kWebsiteURL]   as? String ?? "N/A"
    }

}
