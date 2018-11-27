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

class ViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    let locDefaults = UserDefaults.standard
    let locationManager:CLLocationManager = CLLocationManager()
    let motionActivityManager = CMMotionActivityManager()

    @IBOutlet weak var tableView: UITableView!
    
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

        for currentLocation in locations{
            let Date_time = DateFormatter.localizedString(from: NSDate() as Date,dateStyle:DateFormatter.Style.short,timeStyle:DateFormatter.Style.short)
            let Loc_Lat = String(format: "%.6f",currentLocation.coordinate.latitude)
            let Loc_Lon = String(format: "%.6f",currentLocation.coordinate.longitude)
            print("\(index): \(currentLocation)")
            var Msg = Date_time + ", " + Loc_Lat + ", " + Loc_Lon
            
            if CMMotionActivityManager.isActivityAvailable() {
                motionActivityManager.startActivityUpdates(to: OperationQueue.main) { (motion) in
                    print("inside activity update true")
                    Msg += (motion?.automotive)! ? "Yes Driving\n" : "Not Driving\n"
                    Msg += (motion?.cycling)! ? "Yes Cycling\n" : "Not Cycling\n"
                    Msg += (motion?.walking)! ? "Yes Walking\n" : "Not Walking\n"
                    Msg += (motion?.running)! ? "Yes running\n" : "Not running\n"
                    Msg += (motion?.stationary)! ? "Yes stationary\n" : "Not stationary\n"
                    Msg += (motion?.unknown)! ? "Yes unknown\n" : "Not unknown\n"
                }
            }
            else{
                print("inside activity update false")
            }
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
