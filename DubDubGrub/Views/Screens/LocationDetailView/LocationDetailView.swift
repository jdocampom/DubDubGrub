//
//  LocationDetailView.swift
//  DubDubGrub
//
//  Created by Juan Diego Ocampo on 1/03/22.
//

import SwiftUI
import UIKit

/// MARK: - Main SwiftUI View

struct LocationDetailView: View {
    
    @ObservedObject var viewModel: LocationDetailViewModel
    @Environment(\.sizeCategory) private var sizeCategory
    
    var body: some View {
        ZStack {
            /// Tag: This view contains a VStack with the location banner image, address, description alongside a row of action buttons that allow the user to get walking
            /// directions to that spectific location, make a phone call or go to the location's website. Also, there is a check in/out button that requires the user to have a
            /// profile created in CloudKit.
            Group {
                VStack(spacing: 16) {
                    BannerImageView(image: viewModel.location.bannerImage)
                    LocationAddressAndDescriptionViews(with: viewModel)
                    LocationDetailViewModelActionButtons(with: viewModel)
                    /// Tag: Bottom Section that displays the list of users checked in at a particular location or if there isn't anyone at that
                    /// locations returns a label that says "Nobody's checked in.
                    Group {
                        GridHeaderTextView(text: "Who's Here?").accessibilityLabel(Text(viewModel.createVoiceOverSummary()))
                        ZStack {
                            if viewModel.checkedInProfiles.isEmpty {
                                EmptyGridView()
                            } else {
                                FilledGridView(with: viewModel)
                            }
                            if viewModel.isLoading { LoadingView() }
                        }
                    }
                }
            }
            .accessibilityHidden(viewModel.isShowingProfileModal)
            /// Tag: Modal View that presents the user information about other user's profile picture, name, company and bio. Note that this view only will show up if text size is smaller than .accesibilityMedium.
            if viewModel.isShowingProfileModal {
                Group {
                    ProfileModalViewBackground()
                        .zIndex(1)
                    ProfileModalView(isShowingProfileModal: $viewModel.isShowingProfileModal, profile: viewModel.selectedProfile!)
                        .transition(.opacity.combined(with: .slide))
                        .animation(.easeOut)
                        .zIndex(2)
                }
            }
        }
        /// Tag: Root Navigation View Modifiers
        /// Navigation View Title and Display Mode
        .navigationTitle(viewModel.location.name)
        .navigationBarTitleDisplayMode(.inline)
        /// Modal Sheet that presents the user information about other user's profile picture, name, company and bio. Note that this view only will show up if text size is larger than or equal to than .accesibilityMedium.
        .sheet(isPresented: $viewModel.isShowingProfileSheet) {
            NavigationView {
                ProfileSheetView(profile: viewModel.selectedProfile!)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Dismiss") {
                        viewModel.isShowingProfileSheet = false
                    }
                }
            }
            .accentColor(.brandPrimary)
        }
        /// Alert Modifier
        .alert(item: $viewModel.alertItem, content: { $0.alert })
        /// All methods that gets instantiated here will be called every time the View shows up on the screen
        .onAppear {
            viewModel.getChechedInProfiles()
            viewModel.getCheckedInStatus()
        }
    }
    
}

/// MARK: - SwiftUI Previews

struct LocationDetailViewPreviews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LocationDetailView(viewModel: LocationDetailViewModel(location: DDGLocation(record: MockData.location)))
        }
    }
}

/// MARK: - Complementary SwiftUI Views used at LocationDetailView

fileprivate struct LocationActionButton: View {
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

fileprivate struct FirstNameAvatarView: View {
    @Environment(\.sizeCategory) private var sizeCategory
    var profile: DDGProfile
    var body: some View {
        VStack {
            AvatarView(image: profile.avatarImage, size: sizeCategory >= .accessibilityMedium ? 128: 64)
            Text(profile.firstName)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
    }
}

fileprivate struct BannerImageView: View {
    var image: UIImage
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(height: 120)
            .accessibilityHidden(true)
    }
}

fileprivate struct AddressView: View {
    var address: String
    var body: some View {
        Label(address, systemImage: "mappin.and.ellipse")
            .font(.subheadline)
            .foregroundColor(.secondary)
            .padding(.horizontal, 5)
    }
}

fileprivate struct DescriptionView: View {
    var text: String
    var body: some View {
        Text(text)
            .minimumScaleFactor(0.75)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal)
    }
}

fileprivate struct CapsuleBackground: View {
    var height: CGFloat
    var body: some View {
        Capsule()
            .frame(height: height)
            .foregroundColor(Color(.secondarySystemBackground))
            .padding(.horizontal)
    }
}

fileprivate struct GridHeaderTextView: View {
    var text: String
    var body: some View {
        Text(text)
            .bold()
            .font(.title2)
            .accessibilityAddTraits(.isHeader)
            .accessibilityHint(Text("Bottom section is scrollable"))
    }
}

fileprivate struct EmptyGridView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Nobody's Here 😔")
                .bold()
                .font(.title2)
                .foregroundColor(.secondary)
                .padding(.top, 30)
                .accessibilityHidden(true)
            Spacer()
        }
    }
}

fileprivate struct FilledGridView: View {
    @Environment(\.sizeCategory) private var sizeCategory
    @ObservedObject var viewModel: LocationDetailViewModel
    var body: some View {
        ScrollView {
            LazyVGrid(columns: viewModel.determineColumns(for: sizeCategory), content: {
                ForEach(viewModel.checkedInProfiles) { profile in
                    FirstNameAvatarView(profile: profile)
                        .accessibilityElement(children: .ignore)
                        .accessibilityAddTraits(.isButton)
                        .accessibilityHint(Text("Show's \(profile.firstName) profile pop up."))
                        .accessibilityLabel(Text("\(profile.firstName) \(profile.lastName)"))
                        .onTapGesture {
                            viewModel.show(profile, in: sizeCategory)
                        }
                }
            })
        }
    }
    
    init(with: LocationDetailViewModel) { self.viewModel = with }
    
}

fileprivate struct ProfileModalViewBackground: View {
    var body: some View {
        Color(.systemBackground)
            .ignoresSafeArea()
            .opacity(0.9)
            .transition(AnyTransition.opacity.animation(.easeOut(duration: 0.35)))
            .accessibility(hidden: true)
    }
}

fileprivate struct LocationAddressAndDescriptionViews: View {
    @ObservedObject var viewModel: LocationDetailViewModel
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                AddressView(address: viewModel.location.address)
                Spacer()
            }
            DescriptionView(text: viewModel.location.description)
        }
        .padding(.horizontal, 16)
    }
    
    init(with: LocationDetailViewModel) { self.viewModel = with }
    
}

fileprivate struct LocationDetailViewModelActionButtons: View {
    @ObservedObject var viewModel: LocationDetailViewModel
    var body: some View {
        HStack(spacing: 20) {
            Button(action: viewModel.getDirectionsToLocation) {
                LocationActionButton(color: .brandPrimary, name: "location.fill")
                    .accessibilityLabel(Text("Get directions"))
            }
            Link(destination: URL(string: viewModel.location.websiteURL)!) {
                LocationActionButton(color: .brandPrimary, name: "network")
                    .accessibilityRemoveTraits(.isButton)
                    .accessibilityLabel(Text("Go to website"))
            }
            Button(action: viewModel.callLocation) {
                LocationActionButton(color: .brandPrimary, name: "phone.fill")
                    .accessibilityLabel(Text("Call location"))
            }
            if let _ = CloudKitManager.shared.profileRecordID {
                Button {
                    viewModel.updateCheckInStatus(to: viewModel.isCheckedIn ? .checkedOut : .checkedIn)
                } label: {
                    LocationActionButton(color: viewModel.buttonColor, name: viewModel.buttonLabel)
                        .accessibility(label: Text(viewModel.accesibilityLabel))
                }
                .disabled(viewModel.isLoading)
            }
        }
        .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
        .background(Color(.secondarySystemBackground))
        .clipShape(Capsule())
    }
    
    init(with: LocationDetailViewModel) { self.viewModel = with }
    
}
