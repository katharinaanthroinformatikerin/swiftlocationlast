//
//  MapViewController.swift
//  moapk
//
//  Created by user133257 on 12/9/17.
//  Copyright © 2017 Client5. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MyPin : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String){
        self.coordinate = coordinate
        self.title = title
    }
}

class MapViewController: UIViewController, StationDelegate {
    var locationManager = CLLocationManager()
    var pins = [MKAnnotation]()
    var stations = [Station]()
    var stationsSetInPrefs = [Station]()
    var stationLoader : StationLoader? = nil
    //var strainPrefs : Bool?
    //var subwayPrefs : Bool?
    
    @IBOutlet weak var mapView: MKMapView!
    @IBAction func refreshButton(_ sender: Any) {
        print("in function refresh")
        stationLoader?.load()
    }
    
    
    //unregistering updates when ViewController is destroyed
    deinit {
        NotificationCenter.default.removeObserver(self, name: UserDefaults.didChangeNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestWhenInUseAuthorization()
        mapView.userTrackingMode = .follow
        
        stationLoader = StationLoader(delegate: self)
        stationLoader?.load()
        
        UserDefaults.standard.register(defaults: ["strain_preference" : true, "subway_preference" : true])
        //strainPrefs = UserDefaults.standard.bool(forKey: "strain_preference")
        //subwayPrefs = UserDefaults.standard.bool(forKey: "subway_preference")
        
        //Registering ViewController for updates concerning the app settings
        NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification, object: nil, queue: nil, using: settingsChanged)
        
    }
    
    //What to do when app settings change
    func settingsChanged(notification: Notification){
        
        //UserDefaults.standard.synchronize()
        
        //print("Settings changed")
        //print(UserDefaults.standard.bool(forKey: "strain_preference"))
        //print(UserDefaults.standard.bool(forKey: "subway_preference"))
        
        //strainPrefs = UserDefaults.standard.bool(forKey: "strain_preference")
        //subwayPrefs = UserDefaults.standard.bool(forKey: "subway_preference")
        //print("3 Preferences")
        //print(strainPrefs)
        //print(subwayPrefs)
        
        setStationsSetInPrefs(using: stations)
        
        self.pins.forEach{mapView.removeAnnotation($0)}
        self.pins = []
        
        for station in self.stationsSetInPrefs {
            let lat = station.location.latitude
            let lon = station.location.longitude
            
            let pin = MyPin(coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lon)), title: station.name)
            
            self.pins.append(pin)
            self.mapView.addAnnotation(pin)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //StationDelegate:
    func finishedLoadingStations(_ data: [Station]) {
        
        stations = data
        
        DispatchQueue.main.async{
            
            self.setStationsSetInPrefs(using: data)
            
            self.pins.forEach{self.mapView.removeAnnotation($0)}
            self.pins = []
            
            for station in self.stationsSetInPrefs {
                let lat = station.location.latitude
                let lon = station.location.longitude
                
                let pin = MyPin(coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lon)), title: station.name)
                
                self.pins.append(pin)
                self.mapView.addAnnotation(pin)
            }
        }
    }
    
    func setStationsSetInPrefs(using usstations: [Station]){
        //print("4 Preferences")
        //print(strainPrefs)
        //print(subwayPrefs)
        stationsSetInPrefs = [Station]()
        
        let strainPrefs = UserDefaults.standard.bool(forKey: "strain_preference")
        let subwayPrefs = UserDefaults.standard.bool(forKey: "subway_preference")
        
        
        if (strainPrefs == true && subwayPrefs == true) {
            stationsSetInPrefs = usstations
            
        } else if (strainPrefs == true && subwayPrefs == false) {
            for station in usstations{
                if (station.isSBahn()){
                    stationsSetInPrefs.append(station)
                }
            }
        } else if (strainPrefs == false && subwayPrefs == true) {
            for station in usstations {
                if(station.isUBahn()){
                    stationsSetInPrefs.append(station)
                }
            }
        } else {
            stationsSetInPrefs = [Station]()
        }
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension Double {
    static func random() -> Double {
        return Double(arc4random_uniform(1000000)) / 1000000.0;
    }
}
