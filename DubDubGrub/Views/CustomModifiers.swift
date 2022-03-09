//
//  CustomModifiers.swift
//  DubDubGrub
//
//  Created by Juan Diego Ocampo on 3/03/22.
//

import SwiftUI

struct ProfileNameText: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: 32, weight: .bold))
            .truncatedToOneLine()
    }
    
}


struct TruncatedText: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .lineLimit(1)
            .minimumScaleFactor(0.75)
    }
    
}
