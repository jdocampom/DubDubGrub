//
//  ProfileModalView.swift
//  DubDubGrub
//
//  Created by Juan Diego Ocampo on 7/03/22.
//

import SwiftUI

struct ProfileModalView: View {
    
    @Binding var isShowingProfileModal: Bool
    
    var profile: DDGProfile
    
    var body: some View {
        ZStack {
            VStack {
                Spacer().frame(height: 50)
                Text("\(profile.firstName) \(profile.lastName)")
                    .bold()
                    .font(.title2)
                    .truncatedToOneLine()
                    .padding(.horizontal)
                Text(profile.companyName)
                    .bold()
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .truncatedToOneLine()
                    .padding(.horizontal)
                    .accessibilityLabel("Works at \(profile.companyName)")
                Text(profile.bio)
                    .lineLimit(3)
                    .padding(.top, 0.5)
                    .padding([.horizontal, .bottom])
                    .accessibilityLabel("Bio: \(profile.bio)")
                    .padding(.horizontal)
            }
            .frame(width: 300, height: 200)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(16)
            .overlay(
                Button {
                    withAnimation { isShowingProfileModal = false }
                } label: {
                    Image(systemName: "x.circle.fill")
                        .resizable()
                        .foregroundColor(.brandPrimary)
                        .frame(width: 32, height: 32)
                        .offset(x: 10, y: -10)
                        .accessibilityLabel(Text("Close profile pop-up"))
                }, alignment: .topTrailing
            )
            
            Image(uiImage: profile.avatarImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 110, height: 110)
                .clipShape(Circle())
                .shadow(color: .secondary.opacity(0.5), radius: 5, x: 0, y: 5)
                .offset(y: -105)
                .accessibilityHidden(true)
        }
    }
}

struct ProfileModalView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileModalView(isShowingProfileModal: .constant(true), profile: DDGProfile(record: MockData.profile))
    }
}
