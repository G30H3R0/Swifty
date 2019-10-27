//
//  CustomAnnotation.swift
//  GeoHero
//
//  Created by Theodore Cross on 10/26/19.
//  Copyright © 2019 tedTosterone Enterprise. All rights reserved.
//
import UIKit
import Foundation
import MapKit

class CustomAnnotation: NSObject, MKAnnotation
{
    var coordinate: CLLocationCoordinate2D
    var title: String?
    
    init(coor: CLLocationCoordinate2D)
    {
        coordinate = coor
    }
}
