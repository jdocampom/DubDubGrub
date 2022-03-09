//
//  LocationDetailView.swift
//  DubDubGrub
//
//  Created by Juan Diego Ocampo on 1/03/22.
//

import SwiftUI
import UIKit

struct LocationDetailView: View {
    
    @ObservedObject var viewModel: LocationDetailViewModel
    
    var body: some View {
        ScrollView{
            ZStack {
                VStack(spacing: 16) {
                    BannerImageView(image: viewModel.location.createBannerImage())
                    
                    VStack {
                        HStack {
                            AddressView(address: viewModel.location.address)
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        DescriptionView(text: viewModel.location.description)
                    }
                    .padding(.horizontal, 16)
                    ZStack {
                        Capsule()
                            .frame(height: 80)
                            .foregroundColor(Color(.secondarySystemBackground))
                        
                        HStack(spacing: 20) {
                            Button {
                                viewModel.getDirectionsToLocation()
                            } label: {
                                LocationActionButton(color: .brandPrimary, name: "location.fill")
                                    .accessibilityLabel(Text("Get directions"))
                            }
                            
                            Link(destination: URL(string: viewModel.location.websiteURL)!, label: {
                                LocationActionButton(color: .brandPrimary, name: "network")
                                    .accessibilityRemoveTraits(.isButton)
                                    .accessibilityLabel(Text("Go to website"))
                            })
                            
                            Button {
                                viewModel.callLocation()
                            } label: {
                                LocationActionButton(color: .brandPrimary, name: "phone.fill")
                                    .accessibilityLabel(Text("Call location"))
                            }
                            if let _ = CloudKitManager.shared.profileRecordID {
                                Button {
                                    viewModel.updateCheckInStatus(to: viewModel.isCheckedIn ? .checkedOut : .checkedIn)
                                    playHaptic()
                                } label: {
                                    LocationActionButton(color: viewModel.isCheckedIn ? .grubRed : .brandPrimary,
                                                         name: viewModel.isCheckedIn ? "person.fill.xmark" : "person.fill.checkmark")
                                    .accessibility(label: Text(viewModel.isCheckedIn ? "Check out" : "Check in"))
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Text("Who's Here?")
                        .bold()
                        .font(.title2)
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityLabel(Text(viewModel.createVoiceOverSummary()))
                        .accessibilityHint(Text("Bottom section is scrollable"))
                    
                    ZStack {
                        if viewModel.checkedInProfiles.isEmpty {
                            Spacer()
                            Text("Nobody's Here 😔")
                                .bold()
                                .font(.title2)
                                .foregroundColor(.secondary)
                                .padding(.top, 30)
                                .accessibilityHidden(true)
                            Spacer()
                        } else {
                            ScrollView {
                                LazyVGrid(columns: viewModel.columns, content: {
                                    ForEach(viewModel.checkedInProfiles) { profile in
                                        FirstNameAvatarView(profile: profile)
                                            .accessibilityElement(children: .ignore)
                                            .accessibilityAddTraits(.isButton)
                                            .accessibilityHint(Text("Show's \(profile.firstName) profile pop-up"))
                                            .accessibilityLabel(Text("\(profile.firstName) \(profile.lastName)"))
                                            .onTapGesture {
                                                viewModel.selectedProfile = profile
                                            }
                                    }
                                })
                            }
                        }
                        
                        if viewModel.isLoading { LoadingView() }
                    }
                    
                    Spacer()
                }
                .accessibilityHidden(viewModel.isShowingProfileModal)
                
                
                if viewModel.isShowingProfileModal {
                    Color(.systemBackground)
                        .ignoresSafeArea()
                        .opacity(0.9)
                    //                    .transition(.opacity)
                        .transition(AnyTransition.opacity.animation(.easeOut(duration: 0.35)))
                        .zIndex(1)
                        .accessibility(hidden: true)
                    
                    ProfileModalView(isShowingProfileModal: $viewModel.isShowingProfileModal,
                                     profile: viewModel.selectedProfile!)
                    .transition(.opacity.combined(with: .slide))
                    .animation(.easeOut)
                    .zIndex(2)
                }
            }
        }
        .onAppear {
            viewModel.getChechedInProfiles()
            viewModel.getCheckedInStatus()
        }
        .alert(item: $viewModel.alertItem, content: { alertItem in
            Alert(title: alertItem.title, message: alertItem.message, dismissButton: alertItem.dismissButton)
        })
        .navigationTitle(viewModel.location.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LocationDetailViewPreviews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LocationDetailView(viewModel: LocationDetailViewModel(location: DDGLocation(record: MockData.location)))
        }
    }
}

struct LocationActionButton: View {
    var color: Color
    var name: String
    var body: some View {
        ZStack {
            Circle()
                .foregroundColor(color)
                .frame(width: 60, height: 60)
            Image(systemName: name)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.white)
                .frame(width: 22, height: 22)
        }
    }
}

struct FirstNameAvatarView: View {
    var profile: DDGProfile
    var body: some View {
        VStack {
            AvatarView(image: profile.createAvatarImage(), size: 64)
            Text(profile.firstName)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
    }
}

struct BannerImageView: View {
    var image: UIImage
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(height: 120)
            .accessibilityHidden(true)
    }
}

struct AddressView: View {
    var address: String
    var body: some View {
        Label(address, systemImage: "mappin.and.ellipse")
            .font(.subheadline)
            .foregroundColor(.secondary)
    }
}

struct DescriptionView: View {
    var text: String
    var body: some View {
        Text(text)
            .frame(height: 70)
            .lineLimit(3)
            .minimumScaleFactor(0.75)
            .padding(.horizontal)
    }
}

struct CapsuleBackground: View {
    var height: CGFloat
    var body: some View {
        Capsule()
            .frame(height: height)
            .foregroundColor(Color(.secondarySystemBackground))
            .padding(.horizontal, 5)
    }
}