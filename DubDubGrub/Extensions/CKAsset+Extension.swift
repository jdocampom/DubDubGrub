//
//  CKAsset+Extension.swift
//  DubDubGrub
//
//  Created by Juan Diego Ocampo on 4/03/22.
//

import CloudKit
import UIKit

extension CKAsset {
    
    /// Tag: This function converts a CKAsset into a UIImage

    func convertToUIImage(in dimension: ImageDimension) -> UIImage {
        
        let placeholder   = ImageDimension.getPlaceholder(for: dimension)
        guard let fileUrl = self.fileURL else { return placeholder }
        
        do {
            let data = try Data(contentsOf: fileUrl)
            return UIImage(data: data) ?? placeholder
        } catch {
            return placeholder
        }
        
    }
    
}
