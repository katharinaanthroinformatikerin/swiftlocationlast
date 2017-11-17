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
    
    
    
    //MARK: Initialization
    
    init?(name: String){
        
        //Initialization should fail if there is no name or if the rating is negative.
        if name.isEmpty{
            return nil
        }
        
        
        //Initialize stored properties
        self.name = name
    }
}
