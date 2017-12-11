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

class MapViewController: UIViewController {
    var locationManager = CLLocationManager()
    var pins = [MKAnnotation]()
    
    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestWhenInUseAuthorization()
        mapView.userTrackingMode = .follow
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
