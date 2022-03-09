//
//  DubDubGrubApp.swift
//  DubDubGrub
//
//  Created by Juan Diego Ocampo on 1/03/22.
//

import SwiftUI

@main
struct DubDubGrubApp: App {
    
    let locationManager = LocationManager()
    var body: some Scene {
        WindowGroup {
            AppTabView().environmentObject(locationManager)
        }
    }
    
}
