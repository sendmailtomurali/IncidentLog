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
        lbl_Driving.text = MyDriving
        lbl_Stationary.text = MyStationary
        lbl_walking.text = MyWalking
        lbl_unknown.text = MyUnknown
    }
    


    @IBAction func saveIncident(_ sender: Any) {
        IncidentController.addIncident(newIncident: textField.text!)
        dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
