//
//  AlertItem.swift
//  DubDubGrub
//
//  Created by Juan Diego Ocampo on 4/03/22.
//

import SwiftUI

struct AlertItem: Identifiable {
    
    let id              = UUID()
    let title           : Text
    let message         : Text
    let dismissButton   : Alert.Button
    
}

struct AlertContext {
    
    /// Tag: MapView Errors
    static let unableToGetLocations         = AlertItem(title: Text("Error"),
                                                        message: Text("Unable to retrieve locations at this time. \n\nPlease try again."),
                                                        dismissButton: .default(Text("Dismiss")))
    
    /// Tag: CoreLocation Errors
    static let locationRestricted           = AlertItem(title: Text("Locations Restricted"),
                                                        message: Text("Your current location could not be accessed. This might be due to parental controls."),
                                                        dismissButton: .default(Text("Dismiss")))
    static let locationDenied               = AlertItem(title: Text("Locations Denied"),
                                                        message: Text("DudDubGrub does not have permission to access your location. Please enable       Location Services for this app by going to Settings → DubDubGrub → Location → While Using       the App"),
                                                        dismissButton: .default(Text("Dismiss")))
    static let locationDisabled             = AlertItem(title: Text("Locations Service Denied"),
                                                        message: Text("Your phone's location services are Disabled. Please enable Location Services         for this app by going to Settings → Privacy → Location Services"),
                                                        dismissButton: .default(Text("Dismiss")))
            
    /// Tag: ProfileView Errors
    static let invalidProfile               = AlertItem(title: Text("Invalid Profile"),
                                                        message: Text("All fields are required as well as a profile picture. Your bio must not      contain more than 100 characters. \n\nPlease try again."),
                                                        dismissButton: .default(Text("Dismiss")))
    static let noUserRecord                 = AlertItem(title: Text("Error"),
                                                        message: Text("We couldn't find any user records. This might be due to not being signed into        iCloud on your device."),
                                                        dismissButton: .default(Text("Dismiss")))
    static let createProfileSuccess         = AlertItem(title: Text("Profile Created"),
                                                        message: Text("Your profile has been saved to iCloud successfully."),
                                                        dismissButton: .default(Text("Dismiss")))
    static let createProfileError           = AlertItem(title: Text("Error Creating Profile"),
                                                        message: Text("There's been an error when trying to save your profile to iCloud. \n\nPlease         try again later."),
                                                        dismissButton: .default(Text("Dismiss")))
    static let fetchingProfileError         = AlertItem(title: Text("Error Fetching Profile"),
                                                        message: Text("There's been an error when trying to fetch your profile from iCloud.         \n\nPlease try again later."),
                                                        dismissButton: .default(Text("Dismiss")))
    static let updateProfileSuccess         = AlertItem(title: Text("Profile Updated"),
                                                        message: Text("Your profile has been saved to iCloud successfully."),
                                                        dismissButton: .default(Text("Dismiss")))
    static let updateProfileError           = AlertItem(title: Text("Error Updating Profile"),
                                                        message: Text("There's been an error when trying to save your profile to iCloud. \n\nPlease try again later."),
                                                        dismissButton: .default(Text("Dismiss")))
    
    /// Tag: LocationDetailView Errors
    static let deviceCantMakeCalls          = AlertItem(title: Text("Error"),
                                                        message: Text("Your current device does not support making calls through mobile data. \n\nIf you're using an iPhone check either if airplane mode is on or if cellular connectivity is poor and try again."),
                                                        dismissButton: .default(Text("Dismiss")))
    static let invalidPhoneURL              = AlertItem(title: Text("Error"),
                                                        message: Text("The phone number for the location is invalid. \n\nPlease report this to Customer Support."),
                                                        dismissButton: .default(Text("Dismiss")))
    static let unableToGetCheckInStatus     = AlertItem(title: Text("Server Error"),
                                                        message: Text("We were unable to get your current check-in status for this location. \n\nPlease try again later."),
                                                        dismissButton: .default(Text("Dismiss")))
    static let unableToCheckInOrOut         = AlertItem(title: Text("Server Error"),
                                                        message: Text("We were unable to set your current check-in status for this location. \n\nPlease try again later."),
                                                        dismissButton: .default(Text("Dismiss")))
    static let unableToGetCheckedInProfiles = AlertItem(title: Text("Server Error"),
                                                        message: Text("We were unable to get the list of checked-in users for this location. \n\nPlease try again later."),
                                                        dismissButton: .default(Text("Dismiss")))
    
}
