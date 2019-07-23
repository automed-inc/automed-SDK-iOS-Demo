//
//  ViewController.swift
//  automedSDKTest
//
//  Created by yuhanxiao on 5/21/19.
//  Copyright © 2019 Automed Pty Ltd. All rights reserved.
//

import UIKit
import automedSDK

class ViewController: UIViewController {
    
    //create automed object as a local variable
    var a = automed()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //pass the viewController to the automed object
        a = automed(vc: self)
        //create a automed floating button in your view controller
        a.createAutomedButton(x: self.view.frame.width - 56 - 50, y: self.view.frame.height - 56 - 50, width: 80, height: 80)
    }
    
    @IBAction func connectTest(_ sender: UIButton) {
        //searching for the automed device and create connection
        self.a.connect()
    }
    
    @IBAction func disconnectTest(_ sender: UIButton) {
        //disconnect from all connected automed devices
        a.disconnect()
    }
    
    @IBAction func primeTest(_ sender: UIButton) {
        //check if there is a connected device
        if a.devices.count == 0 {
            print("no device connected")
            return
        }
        //set the first device into Prime mode
        self.a.prime(device: a.devices[0])
    }
    
    @IBAction func RFIDTest(_ sender: UIButton) {
        //check if there is a connected device
        if a.devices.count == 0 {
            print("no device connected")
            return
        }
        //set the first device into individual RFID mode
        self.a.RFID(device: a.devices[0], rfidMode: 1)
        sleep(10)
        //turn off the RFID mode on this device
        self.a.RFID(device: a.devices[0], rfidMode: 0)
        sleep(1)
        //set this device into group RFID mode
        self.a.RFID(device: a.devices[0], rfidMode: 2)
        sleep(10)
        //turn off the RFID mode on this device
        self.a.RFID(device: a.devices[0], rfidMode: 0)
    }
    
    @IBAction func setUnitTest(_ sender: UIButton) {
        //set current weight unit to 'kg'
        self.a.setUnit(unit: "kg")
        //set current weight unit to 'lbs'
        self.a.setUnit(unit: "lbs")
    }
    
    @IBAction func getDataTest(_ sender: UIButton) {
        //Use automed sandbox account to login and get the token
        automedHttpService().login(email: "sandbox@automed.io", password: "AutomedSandbox") { (status, json) in
            if status {
                //succeed, print the token
                print(json!["token"] as! String)
                let token = json!["token"] as! String
                //use the token you get to request the user detail
                automedHttpService().getUserDetail(token: token) { (status, json) in
                    if status {
                        print(json!["id"] as! String)
                    }
                }
                //use the token you get to request the farm information
                automedHttpService().getFarm(token: token) { (status, json) in
                    if status {
                        for farm in json as! [[String : AnyObject]]{
                            print(farm["id"] as! String)
                            print(farm["industry"] as! String)
                        }
                    }
                }
                //use site AutomedSandbox as an example to get the ref treatment data
                automedHttpService().getRefTreatmentData(farmId: "17d5bc35-3370-11e7-b3cb-025fef29a437", token: token) { (status, json) in
                    if status {
                        print(json as! [[String : AnyObject]])
                    }
                }
            }
            else {
                print("failed")
                //do nothing
            }
        }
    }
    
    @IBAction func fixDoseTest(_ sender: UIButton) {
        //check if there is a connected device
        if a.devices.count == 0 {
            print("no device connected")
            return
        }
        //create an alert view with text field for user to enter the amID
        let alert = UIAlertController(title: "amID", message: "Enter the quantity", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = NSLocalizedString("ID", comment: "")
            textField.keyboardType = .decimalPad
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { action -> Void in})
        alert.addAction(UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .default, handler: { [weak alert] (_) in
            let amID = alert?.textFields![0]
            //use user Automed Sandbox and farm Automed Sandbox as example. The industry type should be "Beef"
            //configure the adapter using the input amID
            self.a.configureAdapterForFixDose(device: self.a.devices[0], amID: Int(amID?.text ?? "520")!, userID: "1e776f93-3371-11e7-b3cb-025fef29a437", farmID: "17d5bc35-3370-11e7-b3cb-025fef29a437", industryType: "Beef")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func manualDoseTest(_ sender: UIButton) {
        //check if there is a connected device
        if a.devices.count == 0 {
            print("no device connected")
            return
        }
        //create an alert view with text field for user to enter the dose amount
        let alert = UIAlertController(title: "Dose", message: "Enter the dose", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = NSLocalizedString("dose", comment: "")
            textField.keyboardType = .decimalPad
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { action -> Void in})
        alert.addAction(UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .default, handler: { [weak alert] (_) in
            let dose = alert?.textFields![0]
            //use user Automed Sandbox and farm Automed Sandbox as example. The industry type should be "Beef". Use 531 as amID (1kg/1ml)
            //configure the adapter using the input dose amount
            self.a.configureAdapterForManualDose(device: self.a.devices[0], amID: 531, userID: "1e776f93-3371-11e7-b3cb-025fef29a437", farmID: "17d5bc35-3370-11e7-b3cb-025fef29a437", industryType: "Beef", dose: Double(dose?.text ?? "2")!)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func weightBasedDoseTest(_ sender: UIButton) {
        //check if there is a connected device
        if a.devices.count == 0 {
            print("no device connected")
            return
        }
        //create an alert view with text field for user to enter the weight amount
        let alert = UIAlertController(title: "Weight", message: "Enter the weight", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = NSLocalizedString("weight", comment: "")
            textField.keyboardType = .decimalPad
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { action -> Void in})
        alert.addAction(UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .default, handler: { [weak alert] (_) in
            let weight = alert?.textFields![0]
            //use user Automed Sandbox and farm Automed Sandbox as example. The industry type should be "Beef". Use 531 as amID (1kg/1ml)
            //configure the adapter using the input weight amount
            self.a.configureAdapterForWeightBasedDose(device: self.a.devices[0], amID: 531, userID: "1e776f93-3371-11e7-b3cb-025fef29a437", farmID: "17d5bc35-3370-11e7-b3cb-025fef29a437", industryType: "Beef", weight: Double(weight?.text ?? "520")!)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func getLastTreatmentTest(_ sender: UIButton) {
        //get the latest treatment object
        let treatment = self.a.getLatestTreatmentRecord()
        //print out the amID for this treatment
        print(treatment.getRefTreatmentsAmId())
        //print out the dose amount for this treatment
        print(treatment.getTrDose())
    }
    
    @IBAction func getAllTreatmentTest(_ sender: UIButton) {
        //get all the treatment objects
        let treatments = self.a.getAllTreatmentRecords()
        for treatment in treatments {
            //print out the amID for each treatment
            print(treatment.getRefTreatmentsAmId())
            //print out the dose amount for each treatment
            print(treatment.getTrDose())
        }
    }
    
    @IBAction func syncFromDeviceTest(_ sender: UIButton) {
        //check if there is a connected device
        if a.devices.count == 0 {
            print("no device connected")
            return
        }
        //request the device to send treatment records
        self.a.syncRecordsFromDevice(device: self.a.devices[0])
    }
    
}

