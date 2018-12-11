//
//  ViewController.swift
//  IncidentLog
//
//  Created by Kalaiselvi Krishnan on 11/26/18.
//  Copyright © 2018 Kalaiselvi Krishnan. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications
import CoreMotion
import CallKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var Driving_Label: UILabel!
    @IBOutlet weak var Stationary_Label: UILabel!
    @IBOutlet weak var Cycling_Label: UILabel!
    @IBOutlet weak var confidenceLabel: UILabel!
    @IBOutlet weak var CallState_Label: UILabel!
    
    let locDefaults = UserDefaults.standard
    let sharedPref = UserDefaults.standard
    let locationManager:CLLocationManager = CLLocationManager()
    let motionActivityManager = CMMotionActivityManager()
    var Msg = "First"
    var Confid = "New"
    var callObs : CXCallObserver!
    var callObserver: CXCallObserver!
    @IBOutlet weak var Label: UILabel!
    
    @IBAction func ScreenChg(_ sender: Any) {
        performSegue(withIdentifier: "Segue", sender: self)
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let IncidentLogViewController = segue.destination as! IncidentLogViewController
        //pass data from here
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Krishnan:Notification Parameters
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAllow, Error in})
        
        //Krishnan: Location Update settings
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startMonitoringSignificantLocationChanges()
        self.locationManager.allowsBackgroundLocationUpdates = true
        self.locationManager.pausesLocationUpdatesAutomatically = false
        
        self.sharedPref.setValue(false, forKey: "clstate")//flag for call state setting default:false
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //starting call observer to check user is in call or not
        self.callObs = CXCallObserver()
        self.callObs.setDelegate(self as CXCallObserverDelegate, queue: nil)
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone() as TimeZone
        if CMMotionActivityManager.isActivityAvailable() {
            motionActivityManager.startActivityUpdates(to: OperationQueue.main) { (motion) in
                self.Driving_Label.text = (motion?.automotive)! ? "Driving" : "Not Driving"
                self.Cycling_Label.text = (motion?.cycling)! ? "Yes Cycling" : "Not Cycling"
                self.Stationary_Label.text = (motion?.stationary)! ? "Yes stationary" : "Not stationary"
                //self.Msg = (motion?.automotive)! ? "Yes Driving\n" : "Not Driving\n"
                //self.Msg += (motion?.cycling)! ? "Yes Cycling\n" : "Not Cycling\n"
                //self.Msg += (motion?.running)! ? "Yes running\n" : "Not running\n"
                //self.Msg += (motion?.walking)! ? "Yes Walking\n" : "Not Walking\n"
                //self.Wlk = (motion?.walking)! ? "Yes Walking\n" : "Not Walking\n"
                //self.Msg += (motion?.stationary)! ? "Yes stationary\n" : "Not stationary\n"
                //self.Msg += (motion?.unknown)! ? "Yes unknown\n" : "Not unknown\n"
                //self.Unk = (motion?.unknown)! ? "Yes unknown\n" : "Not unknown\n"

                if motion?.confidence == CMMotionActivityConfidence.low {
                    self.confidenceLabel.text = "Low"
                } else if motion?.confidence == CMMotionActivityConfidence.medium {
                    self.confidenceLabel.text = "Good"
                } else if motion?.confidence == CMMotionActivityConfidence.high {
                    self.confidenceLabel.text = "High"
                    self.Confid = "High"
                }
            }
        }
        else{
            
            self.Msg = "No Data Available"
        }

        for currentLocation in locations{
            let Date_time = DateFormatter.localizedString(from: NSDate() as Date,dateStyle:DateFormatter.Style.short,timeStyle:DateFormatter.Style.short)
            let Loc_Lat = String(format: "%.6f",currentLocation.coordinate.latitude)
            let Loc_Lon = String(format: "%.6f",currentLocation.coordinate.longitude)
            print("\(index): \(currentLocation)")
            //Msg += Date_time + ", " + Loc_Lat + ", " + Loc_Lon
            if self.sharedPref.bool(forKey: "clstate") == true {
                if self.Driving_Label.text == "Driving"  && self.confidenceLabel.text == "High"{
                    Notif(msgbody: " Driving While Talking on phone")}
            }
            if self.sharedPref.bool(forKey: "clstate") == false {
                if self.Driving_Label.text == "Not Driving"  && self.confidenceLabel.text == "High"{
                    Notif(msgbody: " Not Driving and No active Call")
                }
            }
            IncidentController.addIncident(newIncident: Msg)
            //Krishnan: This is needed for refresh
           // tableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear( animated )
        //tableView.reloadData()

    }
    override func   didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //Dispose of any resources that can be recreated
    }

}
//Krishnan: Function writtent to notify user
func Notif(msgbody: String){
    
    //Krishnan: Set the notification content
    let content = UNMutableNotificationContent()
    content.title = "Incident Log"
    content.body = msgbody
    content.sound = UNNotificationSound.default

    //Krishnan: Set the notification trigger
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
    
    //Krishnan: Configure the request - combination of content and trigger
    let request = UNNotificationRequest(identifier: "Possible Incidents", content: content, trigger: trigger)
    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
}

//Krishnan:MONITOR FOR PHONE CALL STATUS
extension ViewController: CXCallObserverDelegate {
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        if call.hasEnded == true {
            print("Disconnected")
            self.CallState_Label.text = "Call Inactive"
            self.sharedPref.setValue(false, forKey: "clstate")
        }
        if call.isOutgoing == true && call.hasConnected == false {
            print("Dialing")
        }
        if call.isOutgoing == false && call.hasConnected == false && call.hasEnded == false {
            print("Incoming")
        }
        
        if call.hasConnected == true && call.hasEnded == false {
            print("Connected")
            self.CallState_Label.text = "Call Active"
            self.sharedPref.setValue(true, forKey: "clstate")
        }
    }
}
