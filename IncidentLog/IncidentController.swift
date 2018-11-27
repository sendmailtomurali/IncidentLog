//
//  IncidentController.swift
//  IncidentLog
//
//  Created by Kalaiselvi Krishnan on 11/26/18.
//  Copyright © 2018 Kalaiselvi Krishnan. All rights reserved.
//

import UIKit

class IncidentController: NSObject {
    static var Incident:[String]{
        get {
            
            if let returnValue =
                UserDefaults.standard.object(forKey: "Incident") as? [String] {
                return returnValue
            } else {
                return ["Default"] //Default value
            }
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "Incident")
            UserDefaults.standard.synchronize()
        }
    }
    class func addIncident ( newIncident:String){
        IncidentController.Incident.append(newIncident)
    }
    
    class func removeIncident (atIndex:Int){
        IncidentController.Incident.remove(at: atIndex)
    }
}
