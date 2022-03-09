//
//  ProfileView.swift
//  DubDubGrub
//
//  Created by Sean Allen on 5/19/21.
//

import SwiftUI
import CloudKit

/// MARK: - Main SwiftUI View

struct ProfileView: View {
    
    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        ScrollView {
            ZStack {
                VStack {
                    HStack(spacing: 16) {
                        ZStack {
                            AvatarView(image: viewModel.avatar, size: 84)
                            EditImage()
                        }
                        .accessibilityElement(children: .ignore)
                        .accessibilityAddTraits(.isButton)
                        .accessibilityLabel(Text("Profile Photo"))
                        .accessibilityHint(Text("Tap twice to open the default photo picker to select a new profile picture."))
                        .onTapGesture { viewModel.isShowingPhotoPicker = true }
                        
                        ProfileUserDataView(firstName: $viewModel.firstName, lastName: $viewModel.lastName, companyName: $viewModel.company)
                        
                    }
                    .padding()
                    .frame(width: UIScreen.width - 32, height: 84 + 48)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            CharactersRemainView(currentCount: viewModel.bio.count)
                                .accessibilityAddTraits(.isHeader)
                            Spacer()
                            if viewModel.isCheckedIn {
                                Button(action: viewModel.checkOut) { CheckOutButton() }
                                
                            }
                        }
                        BioTextEditor(text: $viewModel.bio)
                    }
                    .padding(.horizontal, 20)
                    Spacer()
                    Button {
                        viewModel.profileContext == .create ? viewModel.createProfile() : viewModel.updateProfile()
                        dismissKeyboard()
                    } label: {
                        DDGButton(title: viewModel.profileContext == .create ? "Create Profile" : "Update Profile")
                    }
                    .padding(.vertical)
                }
                
                if viewModel.isLoading { LoadingView() }
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(DeviceTypes.isiPhone8Standard ? .inline : .automatic)
        .toolbar { Button(action: dismissKeyboard) { DismissKeyboardButtonLabel() } }
        .onAppear { viewModel.runOnAppearChecks() }
        .alert(item: $viewModel.alertItem, content: { $0.alert })
        .sheet(isPresented: $viewModel.isShowingPhotoPicker) { PhotoPicker(image: $viewModel.avatar) }
    }
    
}

/// MARK: - SwiftUI Previews

fileprivate struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileView()
        }
    }
}

/// MARK: - Complementary SwiftUI Views

fileprivate struct NameBackgroundView: View {
    var body: some View {
        Color(.secondarySystemBackground)
            .frame(height: 130)
            .cornerRadius(12)
            .padding(.horizontal)
    }
}

fileprivate struct EditImage: View {
    var body: some View {
        Image(systemName: "square.and.pencil")
            .resizable()
            .scaledToFit()
            .frame(width: 14, height: 14)
            .foregroundColor(.white)
            .offset(y: 30)
    }
}

fileprivate struct CharactersRemainView: View {
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

fileprivate struct CheckOutButton: View {
    var body: some View {
        Label("Check Out", systemImage: "mappin.and.ellipse")
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.white)
            .padding(10)
            .frame(height: 28)
            .background(Color.grubRed)
            .clipShape(Capsule())
            .accessibilityLabel(Text("Check out of current location."))
    }
}

fileprivate struct BioTextEditor: View {
    var text: Binding<String>
    var body: some View {
        TextEditor(text: text)
            .frame(height: 100)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary, lineWidth: 1))
            .accessibilityHint(Text("This text field is for your bio. It has a character limit of 100."))
    }
}

fileprivate struct DismissKeyboardButtonLabel: View {
    var body: some View {
        Image(systemName: "keyboard.chevron.compact.down")
            .accessibilityElement(children: .ignore)
            .accessibility(label: Text("Dismiss Keyboard"))
    }
}

fileprivate struct ProfileUserDataView: View {
    var firstName: Binding<String>
    var lastName: Binding<String>
    var companyName: Binding<String>
    var body: some View {
        VStack(spacing: 1) {
            TextField("First Name", text: firstName).profileNameStyle()
                .font(.title)
            TextField("Last Name", text: lastName).profileNameStyle()
                .font(.title)
            TextField("Company Name", text: companyName)
        }
        .padding(.trailing, 16)
    }
}
