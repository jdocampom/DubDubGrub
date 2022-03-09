//
//  LocationManager.swift
//  DubDubGrub
//
//  Created by Juan Diego Ocampo on 4/03/22.
//

import Foundation

final class LocationManager  : ObservableObject {
    
    @Published var locations : [DDGLocation] = []
    
    var selectedLocation     : DDGLocation?
    
}
