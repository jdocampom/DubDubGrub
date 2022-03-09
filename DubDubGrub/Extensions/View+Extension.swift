//
//  View+Extension.swift
//  DubDubGrub
//
//  Created by Juan Diego Ocampo on 3/03/22.
//

import SwiftUI

extension View {
    
    func profileNameStyle()   -> some View { self.modifier(ProfileNameText()) }
    
    func truncatedToOneLine() -> some View {  self.modifier(TruncatedText()) }
    
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
    }
    
    
    
    func embedInScrollView() -> some View {
        GeometryReader { geometry in
            ScrollView {
                self.frame(minHeight: geometry.size.height, maxHeight: .infinity)
            }
        }
    }
    
}
