//
//  Station.swift
//  moapk
//
//  Created by Client5 on 17.11.17.
//  Copyright © 2017 Client5. All rights reserved.
//

import UIKit

class Station {
    
    //MARK: Properties
    
    var name: String
    var location: Location
    var lines: [String]
    
    
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
}

class Location {
    var latitude: Float
    var longitude: Float
    
    init(latitude: Float, longitude: Float){
        self.latitude = latitude
        self.longitude = longitude
    }
}
