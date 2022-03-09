//
//  CKRecord+Extension.swift
//  DubDubGrub
//
//  Created by Juan Diego Ocampo on 4/03/22.
//

import CloudKit

extension CKRecord {
    
    func convertToDDGLocation() -> DDGLocation { DDGLocation(record: self) }
    func convertToDDGProfile() -> DDGProfile { DDGProfile(record: self) }
    
}
