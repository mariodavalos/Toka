//
//  PinSucursal.swift
//  Toka
//
//  Created by Martin Viruete Gonzalez on 21/06/16.
//  Copyright © 2016 oOMovil. All rights reserved.
//

import UIKit
import MapKit

class PinSucursal: NSObject, MKAnnotation {
    let title: String?
    let locationName: String
    let discipline: String
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, locationName: String, discipline: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.locationName = locationName
        self.discipline = discipline
        self.coordinate = coordinate
        
        super.init()
    }
    
    var subtitle: String? {
        return locationName
    }
}