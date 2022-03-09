//
//  DDGButton.swift
//  DubDubGrub
//
//  Created by Juan Diego Ocampo on 3/03/22.
//

import SwiftUI

struct DDGButton: View {
    
    var title: String
    var body: some View {
        Text(title)
            .bold()
            .font(.title3)
            .frame(width: UIScreen.screenWidth - 32, height: 52)
            .foregroundColor(.white)
            .background(Color.brandPrimary)
            .clipShape(Capsule())
    }
    
}

struct DDGButton_Previews: PreviewProvider {
    static var previews: some View {
        DDGButton(title: "Create Profile")
    }
}
