//
//  DDGAnnotation.swift
//  DubDubGrub
//
//  Created by Juan Diego Ocampo on 8/03/22.
//

import SwiftUI

struct DDGAnnotation: View {
    var location: DDGLocation
    var number: Int
    var body: some View {
        VStack {
            ZStack {
                MapBalloon()
                    .frame(width: 100, height: 70)
                    .foregroundColor(.brandPrimary)
                Image(uiImage: location.squareImage)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
                    .offset(y: -10)
                    .accessibilityHidden(true)
                if number > 0 {
                    Text("\(min(number, 99))")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .frame(width: 26, height: 18)
                        .foregroundColor(.white)
                        .background(Color.grubRed)
                        .clipShape(Capsule())
                        .offset(x: 20, y:-30)
                }
            }
            Text(location.name)
                .font(.caption)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .frame(width: 100)
                .lineLimit(2)
                .minimumScaleFactor(0.75)
        }
    }
    
    
}

struct DDGAnnotation_Previews: PreviewProvider {
    static var previews: some View {
        DDGAnnotation(location: DDGLocation(record: MockData.location), number: 5)
    }
}
