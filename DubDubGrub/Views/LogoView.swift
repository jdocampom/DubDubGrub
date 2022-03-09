//
//  LogoView.swift
//  DubDubGrub
//
//  Created by Juan Diego Ocampo on 5/03/22.
//

import SwiftUI

struct LogoView: View {
    
    var frameWidth: CGFloat
    
    var body: some View {
        Image(decorative: "ddg-map-logo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: frameWidth)
    }
    
}

struct LogoView_Previews: PreviewProvider {
    static var previews: some View {
        LogoView(frameWidth: 250)
    }
}
