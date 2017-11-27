//
//  StationService.swift
//  moapk
//
//  Created by Client5 on 24.11.17.
//  Copyright © 2017 Client5. All rights reserved.
//

import Foundation


//delegate, um Controller über beim Model aufgetretene Ereignisse zu informieren
protocol StationDelegate {
    func finishedLoadingStations(_ data: [Station])
}

struct StationLoader {
    
    var delegate : StationDelegate?
    init(delegate:StationDelegate){
        self.delegate = delegate
    }
    
    func load(){
        let urlString = "https://data.wien.gv.at/daten/geo?service=WFS&request=GetFeature&version=1.1.0&typeName=ogdwien:OEFFHALTESTOGD&srsName=EPSG:4326&outputFormat=json"
        
        let optionalUrl = URL(string: urlString)
        
        guard let url = optionalUrl else {
            print("Couldn't parse url.")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url){
            data, response, error in
            if let error = error {
                print(error)
                return
            }
            guard let data = data else {
                print("Couldn't get data.")
                return
            }
            
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
                print("Cannot parse JSON data.")
                return
            }
            
            guard let rootJson = json as? [String: Any] else {
                print("Wrong root element.")
                return
            }
            
            guard let featureList = rootJson["features"] as? [[String: Any]] else {
                print("Cannot parse featureList.")
                return
            }
            
            self.parseFeatures(featureList)
        }
        task.resume()
    }
    
    private func parseFeatures(_ features: [[String:Any]]){
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
        }
        
        //sortiert in alphabetischer Reihenfolge
        delegate?.finishedLoadingStations(usStations.sorted{ $0.name < $1.name })
    }
}
