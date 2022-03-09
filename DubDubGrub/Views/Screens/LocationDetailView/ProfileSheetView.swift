//
//  ProfileSheetView.swift
//  DubDubGrub
//
//  Created by Juan Diego Ocampo on 9/03/22.
//

import SwiftUI

struct ProfileSheetView: View {
    
    var profile: DDGProfile
    
    var body: some View {
        
        
        ScrollView {
            
            VStack {
                
                Image(uiImage: profile.createAvatarImage())
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 110, height: 110)
                    .clipShape(Circle())
                    .shadow(color: .secondary.opacity(0.5), radius: 5, x: 0, y: 5)
                    .accessibilityHidden(true)
                    .padding()
                
                Text("\(profile.firstName) \(profile.lastName)")
                    .bold()
                    .font(.title2)
                    .minimumScaleFactor(0.9)
                    .padding()
                
                Text(profile.companyName)
                    .bold()
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .minimumScaleFactor(0.9)
                    .accessibilityLabel("Works at \(profile.companyName)")
                    .padding()
                
                Text(profile.companyName)
                    .bold()
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .accessibilityLabel("Works at \(profile.companyName)")
                    .padding()
                
                Text(profile.bio)
                    .padding([.horizontal, .bottom])
                    .accessibilityLabel("Bio: \(profile.bio)")
                    .padding()
                
            }
            
        }

    }
}

struct ProfileSheetView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSheetView(profile: DDGProfile(record: MockData.profile))
    }
}
