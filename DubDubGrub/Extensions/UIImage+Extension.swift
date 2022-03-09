//
//  UIImage+Extension.swift
//  DubDubGrub
//
//  Created by Juan Diego Ocampo on 5/03/22.
//

import CloudKit
import UIKit

extension UIImage {
    
    func convertToCKAsset() -> CKAsset? {
        guard let urlPath   = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        guard let imageData = jpegData(compressionQuality: 0.25) else { return nil }
        
        let fileUrl         = urlPath.appendingPathComponent("selectedAvatarImage")
        
        do {
            try imageData.write(to: fileUrl)
            return CKAsset(fileURL: fileUrl)
        } catch {
            return nil
        }
    }
    
}
