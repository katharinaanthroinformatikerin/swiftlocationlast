//
//  StationService.swift
//  moapk
//
//  Created by user133257 on 11/26/17.
//  Copyright © 2017 Client5. All rights reserved.
//

import Foundation

struct StationService {
    
    let delegate : StationDelegate
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
            guard let linesAsString = hlinien as? String, let name = htxt as? String else {
                print("Cannot cast lines as String.")
                return
            }
            guard let lng = coordinates[0] as? Float, let lat = coordinates[1] as? Float else {
                print("Cannot cast coordinates.")
                return
            }
            
            let linesArray = linesAsString.components(separatedBy: ",")
            
            if stations.index(forKey: name) == nil {
                stations[name] = Station(name: name, location: Location(latitude: lat, longitude: lng), lines: linesArray)
            } else {
                stations[name]?.lines += linesArray
            }
            
        }
    }
    //already accomplished by dictionary
    //let stationsWithoutDuplicates = mergeStations
    
    delegate.dataLoadingFinished()
    return stations
}
