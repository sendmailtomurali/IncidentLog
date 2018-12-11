//
//  IncidentLogViewController.swift
//  IncidentLog
//
//  Created by Kalaiselvi Krishnan on 11/26/18.
//  Copyright © 2018 Kalaiselvi Krishnan. All rights reserved.
//

import UIKit

class IncidentLogViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var lbl_Driving: UILabel!
    @IBOutlet weak var lbl_Stationary: UILabel!
    @IBOutlet weak var lbl_walking: UILabel!
    @IBOutlet weak var lbl_unknown: UILabel!
    
    var MyDriving = String()
    var MyStationary = String()
    var MyWalking = String()
    var MyUnknown = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    @IBAction func saveIncident(_ sender: Any) {
        IncidentController.addIncident(newIncident: textField.text!)
        dismiss(animated: true, completion: nil)
    }

}
