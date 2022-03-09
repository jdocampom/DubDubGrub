//
//  AppTabView.swift
//  DubDubGrub
//
//  Created by Juan Diego Ocampo on 1/03/22.
//

import SwiftUI

struct AppTabView: View {
    
    @StateObject private var viewModel = AppTabViewModel()
    
    var body: some View {
        TabView {
            LocationMapView()
                .tabItem { Label("Map", systemImage: "map.fill") }
            
            LocationListView()
                .tabItem { Label("Locations", systemImage: "building.2.fill") }
            
            NavigationView { ProfileView() }
                .tabItem { Label("Profile", systemImage: "person.fill") }
        }
        .onAppear {
            CloudKitManager.shared.getUserRecord()
            viewModel.runStartupChecks()
        }
        .accentColor(.brandPrimary)
        .sheet(isPresented: $viewModel.isShowingOnboardingView, onDismiss: viewModel.ckeckIfLocationServicesIsEnabled) {
            OnboardView(isShowingOnboardView: $viewModel.isShowingOnboardingView)
        }
    }
    
}

struct AppTabView_Previews: PreviewProvider {
    static var previews: some View {
        AppTabView()
    }
}
