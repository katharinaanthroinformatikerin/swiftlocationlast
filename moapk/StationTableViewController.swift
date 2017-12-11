//
//  StationTableViewController.swift
//  moapk
//
//  Created by Client5 on 17.11.17.
//  Copyright © 2017 Client5. All rights reserved.
//

import UIKit
import CoreLocation

class StationTableViewController: UITableViewController, StationDelegate, CLLocationManagerDelegate {
    
    
    //MARK: Properties
    
    var stations = [Station]()
    var stationsSetInPrefs = [Station]()
    var stationLoader : StationLoader? = nil
    var stationLoaderMock : StationLoaderMock? = nil
    
    //var strainPrefs : Bool?
    //var subwayPrefs : Bool?
    
    var locationManager = CLLocationManager()
    private var currentLocation: Location? = nil
    
    @IBOutlet weak var heading: UILabel!
    @IBOutlet weak var location: UILabel!
    
    //unregistering updates when ViewController is destroyed
    deinit {
        NotificationCenter.default.removeObserver(self, name: UserDefaults.didChangeNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Setting default values for app settings
        //UserDefaults.standard.register(defaults: ["strain_preference" : true, "subway_preference" : true])
        //strainPrefs = UserDefaults.standard.bool(forKey: "strain_preference")
        //subwayPrefs = UserDefaults.standard.bool(forKey: "subway_preference")
        //print("1 Preferences")
        //print(strainPrefs)
        //print(subwayPrefs)
        
        //Registering ViewController for updates concerning the app settings
        NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification, object: nil, queue: nil, using: settingsChanged)
        //print("2 Preferences")
        //print(strainPrefs)
        //print(subwayPrefs)
        
        
        
        // Load sample data.
        //loadSampleStations()
        stationLoader = StationLoader(delegate: self)
        stationLoader?.load()
        
        self.refreshControl?.addTarget(self, action: #selector(StationTableViewController.refresh(_:)), for: UIControlEvents.valueChanged)
        
        locationSetup()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
        self.tableView.reloadData()
    }
    
    func locationSetup(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 50 // meter
        locationManager.requestWhenInUseAuthorization()
        
        //print(locationManager.location?.coordinate as Any)
        
        /*
        location.text = ""
        heading.text = ""

        if let l = locationManager.location {
            location.text = "\(l)"
        }
        if let h = locationManager.heading {
            heading.text = "\(h)"
        }*/
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.startUpdatingLocation()
        }
        self.tableView.reloadData()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //var currentLocation : CLLocationCoordinate2D = locationManager.location!.coordinate
        
        var lat : Float
        var lng : Float
        if let l = locations.last{
           lat = Float(l.coordinate.latitude)
            lng = Float(l.coordinate.longitude)
        }
        else{
            lat = 0
            lng = 0
        }
        //location
        //last location
        //wenn location null: last location, sonst aktuelle location
        //durch Stationen, Distanz berechnen und setzen
        print(self.currentLocation as Any)
        self.currentLocation = Location(latitude: lat, longitude: lng)
        setLocation(location: self.currentLocation!)
        
        self.tableView.reloadData()

    }
    
    private func setLocation(location: Location) {
        DispatchQueue.global(qos: .background).async {
            for station in self.stationsSetInPrefs{
                station.setDistance(latitude: location.latitude, longitude: location.longitude)
            }
            DispatchQueue.main.async {
                self.stationsSetInPrefs = self.stationsSetInPrefs.sorted{ Float($0.distance!) < Float($1.distance!) }
            }
        }
        self.tableView.reloadData()
    }
    
    private func locationManager(_ manager: CLLocationManager, didFailWithError error: [CLLocation]){
    
    }
    
    
    @objc func refresh(_ sender: Any){
        print("in function refresh")
        stationLoader?.load()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return the number of rows
        return stationsSetInPrefs.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Table view cells are reused and should be dequeued using a cell identifier
        let cellIdentifier = "StationListTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? StationListTableViewCell else {
            fatalError("The dequeued cell is not an instance of StationTableViewCell.")
        }
        
        //Fetches the appropriate station for the data source layout.
        let station = stationsSetInPrefs[indexPath.row]
        
        cell.nameLabel.text = "\(station.name)"
        
        if (station.isSBahn() && station.isUBahn()) {
            cell.iconImageView.image = UIImage(named: "image_subahn")
        }
        else if (station.isUBahn()) {
            cell.iconImageView.image = UIImage(named: "image_ubahn")
        }
        else if (station.isSBahn()){
            cell.iconImageView.image = UIImage(named: "image_sbahn")
        }
        
        var formattedDistance = ""
        if let d = station.distance {
            let rawDistance : Double = d
            formattedDistance = formatDistance(distance: rawDistance)
        }
        //print("DISTANCE: ")
        //print(station.distance)
        DispatchQueue.main.async {
            cell.location.text = "\(String(describing: formattedDistance))"
        }
        
        return cell
    }
    
    func formatDistance(distance: Double) -> String {
        let km = "km"
        let m = "m"
        if(distance/1000 > 1.0 ){
            return "\(String(format: "%.2f ", distance/1000)) \(km)"
        }
        else {
            return "\(String(format: "%.2f", distance)) \(m)"
        }
        
    }
    
    /*func formatDistance(distance: Double) -> String {
        if (distance < 1000){
            return String(format: "%.0f", distance) + " m"
        } else {
            let km = distance
            let m = (km - Double(Int(km))) * 1000
            return String(format: "%.0f", km) + " km " + String(format: "%.0f", m) + " m"
        }
    }*/


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier?.compare("showStationDetails") != nil){
            guard let stationViewController = segue.destination as? StationViewController else {
                fatalError("Unexpected destination \(segue.destination)")
            }
            guard let selectedStationCell = sender as? StationListTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            guard let indexPath = tableView.indexPath(for: selectedStationCell) else {
                fatalError("The selected cell is not displayed in the table.")
            }
            let selectedStation = stationsSetInPrefs[indexPath.row]
            stationViewController.station = selectedStation
        }
    }
    
    
    //MARK: Private Methods
    
    //private func loadSampleStations() {
    //
    //    for _ in 0...29{
    //        let station = Station(name: "Station", location: Location(latitude: 48.134861, longitude: 16.283298), lines: 
    //["A31","A32", "A33"])
    //        stations.append(station)
    //    }
    //}
    
    
    //StationDelegate:
    func finishedLoadingStations(_ data: [Station]) {
        
        stations = data
        
        DispatchQueue.main.async{
            self.setStationsSetInPrefs(using: data)
            if let loc = self.currentLocation {
                self.setLocation(location: loc)
            }
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
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
        
        self.tableView.reloadData()
    }
}
