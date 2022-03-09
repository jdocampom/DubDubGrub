//
//  LocationMapView.swift
//  DubDubGrub
//
//  Created by Juan Diego Ocampo on 1/03/22.
//

import MapKit
import SwiftUI

struct LocationMapView: View {
    
    @EnvironmentObject private var locationManager: LocationManager
    @StateObject private var viewModel = LocationMapViewModel()
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $viewModel.region, showsUserLocation: true, annotationItems: locationManager.locations) { location in
                MapAnnotation(coordinate: location.location.coordinate, anchorPoint: CGPoint(x: 0.5, y: 0.75)) {
                    DDGAnnotation(location: location, number: viewModel.checkedInProfiles[location.id, default: 0])
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(Text(viewModel.createVoiceOverSummary(for: location)))
                        .onTapGesture {
                            locationManager.selectedLocation = location
                            viewModel.isShowingDetailView = true
                        }
                }
            }
            .accentColor(.grubRed)
            .edgesIgnoringSafeArea([.top, .trailing, .leading])
            
            VStack(alignment: .center) {
                LogoView(frameWidth: UIScreen.screenHeight / 8)
                    .shadow(radius: 7.5)
//                    .accessibilityHidden(true)
                Spacer()
            }
        }
        .sheet(isPresented: $viewModel.isShowingDetailView) {
            NavigationView {
                if let location = locationManager.selectedLocation {
                    LocationDetailView(viewModel: LocationDetailViewModel(location: location))
                        .toolbar {
                            Button("Dismiss") {
                                viewModel.isShowingDetailView = false
                                viewModel.getCheckedInCount()
                            }
                        }
                        .accentColor(.brandPrimary)
                }
            }
        }
        .alert(item: $viewModel.alertItem, content: { alertItem in
            Alert(title: alertItem.title, message: alertItem.message, dismissButton: alertItem.dismissButton)
        })
        .onAppear {
            if locationManager.locations.isEmpty { viewModel.getLocations(for: locationManager) }
            viewModel.getCheckedInCount()
        }
    }
    
}

struct LocationMapView_Previews: PreviewProvider {
    static var previews: some View {
        LocationMapView()
    }
}
