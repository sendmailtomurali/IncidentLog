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
//import CallKit

class ViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    let locDefaults = UserDefaults.standard
    let locationManager:CLLocationManager = CLLocationManager()
    let motionActivityManager = CMMotionActivityManager()
    var Msg = "First"
    var Drv = "Dummy"
    var Stn = "New"
   /* var callObs : CXCallObserver!
    var callObserver: CXCallObserver!
    var call_active : Bool = false*/
    @IBOutlet weak var Label: UILabel!
    @IBOutlet weak var confidenceLabel: UILabel!
    @IBAction func ScreenChg(_ sender: Any) {
        performSegue(withIdentifier: "Segue", sender: self)
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var IncidentLogViewController = segue.destination as! IncidentLogViewController
        IncidentLogViewController.MyDriving = Drv
        IncidentLogViewController.MyStationary = Stn
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Krishnan:Notification Parameters
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAllow, Error in})
        
        //Krishnan: Location Update settings
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startMonitoringSignificantLocationChanges()
        self.locationManager.allowsBackgroundLocationUpdates = true
        self.locationManager.pausesLocationUpdatesAutomatically = false
    
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone() as TimeZone
        if CMMotionActivityManager.isActivityAvailable() {
            motionActivityManager.startActivityUpdates(to: OperationQueue.main) { (motion) in
                print("inside activity update true")
                self.Drv = (motion?.automotive)! ? "Yes Driving\n" : "Not Driving\n"
                self.Msg += (motion?.cycling)! ? "Yes Cycling\n" : "Not Cycling\n"
                self.Msg += (motion?.running)! ? "Yes running\n" : "Not running\n"
                self.Msg += (motion?.walking)! ? "Yes Walking\n" : "Not Walking\n"
                self.Label.text = (motion?.stationary)! ? "Yes stationary\n" : "Not stationary\n"
                self.Msg += (motion?.unknown)! ? "Yes unknown\n" : "Not unknown\n"
                
                if motion?.confidence == CMMotionActivityConfidence.low {
                    self.confidenceLabel.text = "Low"
                } else if motion?.confidence == CMMotionActivityConfidence.medium {
                    self.confidenceLabel.text = "Good"
                } else if motion?.confidence == CMMotionActivityConfidence.high {
                    self.confidenceLabel.text = "High"
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
            Msg += Date_time + ", " + Loc_Lat + ", " + Loc_Lon
         //   Msg += "\nCall:"+String(call_active)
            print (Msg)
            Notif(msgbody: "Update Received")
            IncidentController.addIncident(newIncident: Msg)
            //Krishnan: This is needed for refresh
            tableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear( animated )
        tableView.reloadData()

    }
    override func   didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //Dispose of any resources that can be recreated
    }
    //Krishnan: Set the number of sections in the tableview as 1
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //Krishnan: The number of rows within that one section is count of records
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return IncidentController.Incident.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = IncidentController.Incident[indexPath.row]
        //Krishnan:This is needed for message to show data in multiple lines
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //Krishnan:Set the header text
        return "Log Summary"
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
/*
extension ViewController: CXCallObserverDelegate {
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        if call.hasEnded == true {
            print("Disconnected")
            call_active = false
        }
        if call.isOutgoing == true && call.hasConnected == false {
            print("Dialing")
        }
        if call.isOutgoing == false && call.hasConnected == false && call.hasEnded == false {
            print("Incoming")
        }
        
        if call.hasConnected == true && call.hasEnded == false {
            print("Connected")
            call_active = true
        }
    }
}
*/
