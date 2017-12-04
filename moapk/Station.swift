//
//  Station.swift
//  moapk
//
//  Created by Client5 on 17.11.17.
//  Copyright © 2017 Client5. All rights reserved.
//

import UIKit
import CoreLocation

class Station {
    
    //MARK: Properties
    
    var name: String
    var location: Location
    var lines: [String]
    var distance: Double?
    
    
    //MARK: Initialization
    
    init(name: String, location: Location, lines: [String]){
        
        //Initialize stored properties
        self.name = name
        self.location = location
        self.lines = lines
    }
    
    func isUBahn() -> Bool {
        for line in lines {
            if(line.contains("U")){
                return true
            }
        }
        return false
    }
    
    func isSBahn() -> Bool {
        for line in lines {
            if(line.contains("S")){
                return true
            }
        }
        return false
    }
    
    func isUBahnOrSBahn() -> Bool{
        return isSBahn() || isUBahn()
    }
    
    
    func setDistance(latitude: Float, longitude: Float){
        
        let loc = CLLocation(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
        
        let loc2 = CLLocation(latitude: CLLocationDegrees(self.location.latitude), longitude: CLLocationDegrees(self.location.longitude))
        
        self.distance = loc.distance(from: loc2)
    }
    
}

class Location {
    var latitude: Float
    var longitude: Float
    
    init(latitude: Float, longitude: Float){
        self.latitude = latitude
        self.longitude = longitude
    }
}
