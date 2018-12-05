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

class ViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    let locDefaults = UserDefaults.standard
    let sharedPref = UserDefaults.standard
    let locationManager:CLLocationManager = CLLocationManager()
    let motionActivityManager = CMMotionActivityManager()
    var Msg = "First"
    var Drv = "Dummy"
    var Stn = "New"
    var Wlk = "New1"
    var Unk = "Unknown"
    var callObs : CXCallObserver!
    var callObserver: CXCallObserver!
    @IBOutlet weak var Label: UILabel!
    @IBOutlet weak var confidenceLabel: UILabel!
    @IBAction func ScreenChg(_ sender: Any) {
        performSegue(withIdentifier: "Segue", sender: self)
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let IncidentLogViewController = segue.destination as! IncidentLogViewController
        IncidentLogViewController.MyDriving = Drv
        IncidentLogViewController.MyStationary = Stn
        IncidentLogViewController.MyWalking = Wlk
        IncidentLogViewController.MyUnknown = Unk
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
        print("monitoring calls")
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone() as TimeZone
        if CMMotionActivityManager.isActivityAvailable() {
            motionActivityManager.startActivityUpdates(to: OperationQueue.main) { (motion) in
                self.Label.text = (motion?.automotive)! ? "Yes Driving\n" : "Not Driving\n"
                self.Msg = (motion?.automotive)! ? "Yes Driving\n" : "Not Driving\n"
                self.Drv = (motion?.automotive)! ? "Yes Driving\n" : "Not Driving\n"
                self.Msg += (motion?.cycling)! ? "Yes Cycling\n" : "Not Cycling\n"
                self.Msg += (motion?.running)! ? "Yes running\n" : "Not running\n"
                self.Msg += (motion?.walking)! ? "Yes Walking\n" : "Not Walking\n"
                self.Wlk = (motion?.walking)! ? "Yes Walking\n" : "Not Walking\n"
                self.Msg += (motion?.stationary)! ? "Yes stationary\n" : "Not stationary\n"
                self.Stn = (motion?.stationary)! ? "Yes stationary\n" : "Not stationary\n"
                self.Msg += (motion?.unknown)! ? "Yes unknown\n" : "Not unknown\n"
                self.Unk = (motion?.unknown)! ? "Yes unknown\n" : "Not unknown\n"

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
            if self.sharedPref.bool(forKey: "clstate") == true {
            Msg += "\nCall Active"
            }
            if self.sharedPref.bool(forKey: "clstate") == false {
                Msg += "\nCall Inactive"
            }
            print (Msg)
            sendtoserver(Lat: Loc_Lat, Lon: Loc_Lon, Message: Msg)
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

extension ViewController: CXCallObserverDelegate {
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        if call.hasEnded == true {
            print("Disconnected")
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
            self.sharedPref.setValue(true, forKey: "clstate")
        }
    }
}

func sendtoserver(Lat:String,Lon:String,Message: String){
    DispatchQueue.main.async(execute:{
        let token = "'etunEpk-06U:APA91bHiohffPemYEb6ILjSgdRTxdT9jPSZ3UMIOIeq_MqBQS8KberiqUGKyJaofhMqdvFkhN1lEwiUnkbJ5byikqJStZ9krhKWtd5xkGqJb4CyaSjawXlePKg_QAYeYpwcbr6MNooTK'"
        print(token)
        let auth = "JWT \(token)"
        let parameters = ["inc_lat": Lat,"inc_lng": Lon,"inc_speed":0.0,"inc_summary": Message,"inc_parent":1] as [String : Any]
        print(parameters)
        //for testing
        // guard let url = URL (string: "http://ec2-54-191-172-248.us-west-2.compute.amazonaws.com/sandbox/v1/user/incident") else{ return}
        //for production
        guard let url = URL (string: "http://ec2-54-191-172-248.us-west-2.compute.amazonaws.com/api/v1/user/incident") else{ return}
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])else{ return}
        request.httpBody = httpBody
        request.addValue(auth, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            print(request)
            //ramya added 4-7-2018 for verify status code
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                
            }
            else{
                if let data = data{
                    do{//to handle crash
                        print(auth)
                    }catch{
                        print(error)
                    }
                }
            }
            print(response)
            }.resume()
    })
}//token

