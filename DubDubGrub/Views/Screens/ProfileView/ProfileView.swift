//
//  ProfileView.swift
//  DubDubGrub
//
//  Created by Sean Allen on 5/19/21.
//

import SwiftUI
import CloudKit

struct ProfileView: View {
    
    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        ScrollView {
            ZStack {
                VStack {
                    ZStack {
                        NameBackgroundView()
                        
                        HStack(spacing: 16) {
                            ZStack {
                                AvatarView(image: viewModel.avatar, size: 84)
                                EditImage()
                            }
                            .accessibilityElement(children: .ignore)
                            .accessibilityAddTraits(.isButton)
                            .accessibilityLabel(Text("Profile Photo"))
                            .accessibilityHint(Text("Tap twice to open the default photo picker to select a new profile picture."))
                            .padding(.leading, 12)
                            .onTapGesture { viewModel.isShowingPhotoPicker = true }
                            
                            VStack(spacing: 1) {
                                TextField("First Name", text: $viewModel.firstName).profileNameStyle()
                                    .font(.title)
                                TextField("Last Name", text: $viewModel.lastName).profileNameStyle()
                                    .font(.title)
                                TextField("Company Name", text: $viewModel.company)
                            }
                            .padding(.trailing, 16)
                            
                        }
                        .padding()
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            CharactersRemainView(currentCount: viewModel.bio.count)
                                .accessibilityAddTraits(.isHeader)
                            Spacer()
                            
                            if viewModel.isCheckedIn {
                                Button {
                                    viewModel.checkOut()
                                    playHaptic()
                                } label: {
                                    Label("Check Out", systemImage: "mappin.and.ellipse")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(10)
                                        .frame(height: 28)
                                        .background(Color.grubRed)
                                        .clipShape(Capsule())
                                }
                                .accessibilityLabel(Text("Check out of current location."))
                            }
                        }
                        
                        TextEditor(text: $viewModel.bio)
                            .frame(height: 100)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary, lineWidth: 1))
//                            .accessibility(label: Text("Bio: \(viewModel.bio)"))
                            .accessibilityHint(Text("This text field is for your bio. It has a character limit of 100."))
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    Button {
                        viewModel.profileContext == .create ? viewModel.createProfile() : viewModel.updateProfile()
                        playHaptic()
                        dismissKeyboard()
                    } label: {
                        DDGButton(title: viewModel.profileContext == .create ? "Create Profile" : "Update Profile")
                    }
                    .padding(.bottom)
                }
                
                if viewModel.isLoading { LoadingView() }
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(DeviceTypes.isiPhone8Standard ? .inline : .automatic)
        .toolbar {
            Button {
                dismissKeyboard()
            } label: {
                Image(systemName: "keyboard.chevron.compact.down")
                    .accessibilityElement(children: .ignore)
                    .accessibility(label: Text("Dismiss Keyboard"))
            }
        }
        .onAppear {
            viewModel.getProfile()
            viewModel.getCheckedInStatus()
        }
        .alert(item: $viewModel.alertItem, content: { alertItem in
            Alert(title: alertItem.title, message: alertItem.message, dismissButton: alertItem.dismissButton)
        })
        .sheet(isPresented: $viewModel.isShowingPhotoPicker) {
            PhotoPicker(image: $viewModel.avatar)
        }
    }
    
}


struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileView()
        }
    }
}


struct NameBackgroundView: View {
    var body: some View {
        Color(.secondarySystemBackground)
            .frame(height: 130)
            .cornerRadius(12)
            .padding(.horizontal)
    }
}

struct EditImage: View {
    var body: some View {
        Image(systemName: "square.and.pencil")
            .resizable()
            .scaledToFit()
            .frame(width: 14, height: 14)
            .foregroundColor(.white)
            .offset(y: 30)
    }
}

struct CharactersRemainView: View {
    
    var currentCount: Int
    
    var body: some View {
        Text("Bio: ")
            .font(.callout)
            .foregroundColor(.secondary)
        +
        Text("\(100 - currentCount)")
            .bold()
            .font(.callout)
            .foregroundColor(currentCount <= 100 ? .brandPrimary : Color(.systemPink))
        +
        Text(" Characters Remain")
            .font(.callout)
            .foregroundColor(.secondary)
    }
}
