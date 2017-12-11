//
//  StationViewController.swift
//  moapk
//
//  Created by Client5 on 17.11.17.
//  Copyright © 2017 Client5. All rights reserved.
//

import UIKit

class StationViewController: UIViewController {
    
    //MARK: Properties
    @IBOutlet weak var stationnameLabel: UILabel!
    
    @IBOutlet weak var latitudeLabel: UILabel!

    @IBOutlet weak var longitudeLabel: UILabel!
    
    @IBOutlet weak var linesTextView: UITextView!
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var iconImage: UIImageView!
        
    
    
    
    var station: Station?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.stationnameLabel.text = station?.name
        self.latitudeLabel.text = floatToString(float: (station!.location.latitude))
        self.longitudeLabel.text = floatToString(float: (station!.location.longitude))
        
        var formattedDistance = ""
        
        if let d = station?.distance {
            let rawDistance : Double = d
            formattedDistance = formatDistance(distance: rawDistance)
        }

        self.distanceLabel.text = "\(String(describing: formattedDistance))"
        
        if let s = station {
            if (s.isSBahn() && s.isUBahn()) {
            iconImage.image = UIImage(named: "image_subahn")
        }
        else if (s.isUBahn()) {
            iconImage.image = UIImage(named: "image_ubahn")
        }
        else if (s.isSBahn()){
            iconImage.image = UIImage(named: "image_sbahn")
            }
        }
        
        
        
        let unsortedLines = station?.lines
        let sortingPreference = "SU".characters.map {$0}
        var subArray1 = [String]()
        var subArray2 = [String]()
        
        unsortedLines?.forEach{
            if $0.isEmpty || !sortingPreference.contains($0[$0.startIndex]){
                subArray2.append($0)
            } else {
                subArray1.append($0)
            }
        }
        
        subArray1.sort{ str1, str2 in
            let firstChar1 = str1[str1.startIndex]
            let firstChar2 = str2[str2.startIndex]
            
            let index1 = sortingPreference.index(of: firstChar1)!
            let index2 = sortingPreference.index(of: firstChar2)!
            
            if index1 != index2 {
                return index1 < index2
            } else {
                return str1.compare(str2, options: .numeric) == .orderedAscending
            }
        }
        
        subArray2.sort { $0.compare($1, options: .numeric) == .orderedAscending}
        
        station?.lines = subArray1 + subArray2
        
        self.linesTextView.text = station?.lines.joined(separator: "\r\n")
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
    
    private func floatToString(float: Float) -> String{
        return String(format: "%.6f", float)
    }
}

