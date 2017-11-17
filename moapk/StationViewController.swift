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
    
    @IBOutlet weak var linesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
}

