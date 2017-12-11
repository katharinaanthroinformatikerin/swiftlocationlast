//
//  StationService.swift
//  moapk
//
//  Created by Client5 on 24.11.17.
//  Copyright © 2017 Client5. All rights reserved.
//

import Foundation


//delegate, um Controller über beim Model aufgetretene Ereignisse zu informieren
protocol StationDelegateMock {
    func finishedLoadingStations(_ data: [Station])
}
struct StationLoaderMock {
    var stations = [Station]()
    var usStations = [Station]()
    
    
    var delegate : StationDelegate?
    init(delegate: StationDelegate){
        self.delegate = delegate
    }
    
    mutating func load(){
        for i : Int in 0...2 {
            let station = Station(
                name: "Station" + i.description,
                location: Location(latitude: 48.134861, longitude: 16.283298),
                lines: ["A31","A32", "A33"])
            usStations.append(station)
        }
        
        delegate?.finishedLoadingStations(usStations)
    }
    
    //delegate?.finishedLoadingStations(usStations)
    
    /*private func parseFeatures(_ features: [[String:Any]]){
        var stations=[String:Station]()
        
        for feature in features {
            guard let properties = feature["properties"] as? [String:Any] else {
                print("Cannot parse properties.")
                return
            }
            guard let htxt = properties["HTXT"], let hlinien=properties["HLINIEN"] else {
                print("Cannot parse htxt and hlinien.")
                return
            }
            guard let geometry = feature["geometry"] as? [String:Any] else {
                print("Cannot parse geometry.")
                return
            }
            guard let coordinates = geometry["coordinates"] as? [Any] else {
                print("Cannot parse coordinates")
                return
            }
            guard let linesAsString = hlinien as? String else {
                print("Cannot cast lines as String.")
                return
            }
            guard let name = htxt as? String else {
                print("Cannot cast name as String.")
                return
            }
            guard let lng = coordinates[0] as? Float, let lat = coordinates[1] as? Float else {
                print("Cannot cast coordinates.")
                return
            }
            
            let crudeLinesArray = linesAsString.components(separatedBy: ",")
            let linesArray = crudeLinesArray.map{$0.trimmingCharacters(in: .whitespacesAndNewlines)}
            
            //for line in crudeLinesArray{
            //    let cleanLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            //    linesArray.append(cleanLine)
            //}
            
            
            if stations.index(forKey: name) == nil {
                stations[name] = Station(name: name, location: Location(latitude: lat, longitude: lng), lines: linesArray)
            } else {
                stations[name]?.lines += linesArray
            }
        }
        
        let allStations = Array(stations.values.map{$0})
        let usStations = allStations.filter{$0.isUBahnOrSBahn()}
        for station in usStations{
            //removes duplicate lines by transforming into a set and then back to an array
            station.lines = Array(Set(station.lines))
        }*/
        
        //sortiert in alphabetischer Reihenfolge
    //delegate?.finishedLoadingStations(usStations)
    
}
