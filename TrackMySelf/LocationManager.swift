//
//  LocationManager.swift
//  TrackMySelf
//
//  Created by Chuanxun on 16/3/29.
//  Copyright © 2016年 Leon. All rights reserved.
//

import UIKit

class LocationManager: NSObject,CLLocationManagerDelegate {

    
    var systemLocationManager:CLLocationManager!
    
    static let sharedLocationManager:LocationManager = {
       let manager = LocationManager()
        
        manager.systemLocationManager = CLLocationManager()
        manager.systemLocationManager.delegate = manager
        manager.systemLocationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager.systemLocationManager.distanceFilter = 50
        
        if CLLocationManager.locationServicesEnabled() {
            
            if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.Denied {
                if #available(iOS 8.0, *) {
                    manager.systemLocationManager.requestAlwaysAuthorization()
                }
            }
            
        }else{
            if #available(iOS 8.0, *) {
                let alertVc = UIAlertController(title: "", message: "GPS not open", preferredStyle: .Alert)
                let okActioin = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
                alertVc.addAction(okActioin)
                
                UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alertVc, animated: true, completion: nil)
            } else {
                // Fallback on earlier versions
            }

        }
        
        
        return manager
    }()
    
    
    
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .AuthorizedAlways:
            print("AuthorizedAlways")
            self.systemLocationManager.startUpdatingLocation()
        case .Denied:
            print("Denied")
        case .Restricted:
            print("Restricted")
        default:
            break
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userDef = NSUserDefaults.standardUserDefaults()
        let dbStoreToBmob = userDef.boolForKey("DbStoreToBmob")
        
        if dbStoreToBmob {
            if let bmUser = BmobUser.getCurrentUser() {
                let location = locations.first
                let object = BmobObject(className: "locations")
                object.setObject(location?.coordinate.latitude, forKey: "latitude")
                object.setObject(location?.coordinate.longitude, forKey: "longitude")
                object.setObject(NSDate(), forKey: "arriveTime")
                
                let acl = BmobACL()
                acl.setReadAccessForUser(bmUser)
                acl.setWriteAccessForUser(bmUser)
                object.ACL = acl
                
                object.saveInBackgroundWithResultBlock({ (isSuccessful, error) -> Void in
                    if isSuccessful {
                        print("save data ok")
                    }else{
                        print(error)
                    }
                })
            }
        }else{
            let location = locations.first
            L8SqlLite.sharedSqlite.addNewLocation((location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!)
        }      
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
}
