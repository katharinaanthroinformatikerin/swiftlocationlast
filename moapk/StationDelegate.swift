//
//  StationDelegate.swift
//  moapk
//
//  Created by user133257 on 11/26/17.
//  Copyright © 2017 Client5. All rights reserved.
//

//delegate, um Controller über beim Model aufgetretene Ereignisse zu informieren
protocol StationDelegate {
    func dataLoadingFinished(_ data: [Station])
}
