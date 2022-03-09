//
//  OnboardView.swift
//  DubDubGrub
//
//  Created by Juan Diego Ocampo on 5/03/22.
//

import SwiftUI

struct OnboardView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            LogoView(frameWidth: UIScreen.width / 1.5)
                .padding(.vertical)
            Spacer()
            VStack(alignment: .leading, spacing: 20) {
                OnboardInfoView(imageName: "building.2.crop.circle", title: "Restaurant Locations", description: "Find places to dine around the convention center.")
                OnboardInfoView(imageName: "checkmark.circle", title: "Check In", description: "Let other iOS Devs where you are.")
                OnboardInfoView(imageName: "person.2.circle", title: "Find Friends", description: "See where other iOS Devs are and join thr party.")
                Spacer()
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    DDGButton(title: "Continue")
                }
                .padding(.bottom)
            }
        }
        .padding(.horizontal, 20)
    }
    
}

struct OnboardView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardView()
    }
}

fileprivate struct OnboardInfoView: View {
    
    var imageName: String
    var title: String
    var description: String
    
    var body: some View {
        HStack(spacing: 25) {
            Image(systemName: imageName)
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.brandPrimary)
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .bold()
                Text(description)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
            }
        }
        .padding(.vertical)
    }
    
}
