//
//  LocationManager.swift
//  TrackMySelf
//
//  Created by Chuanxun on 16/3/29.
//  Copyright © 2016年 Leon. All rights reserved.
//

import UIKit


class L8Region:NSObject,NSCoding {
    
    var latitude:Double
    var longitude:Double
    var radius:CLLocationDistance
    var identifier:String
    var notifyOnEnter = true
    var notifyOnExit = true
    
    var location:CLLocation {
        get {
            return CLLocation(latitude: self.latitude, longitude: self.longitude)
        }
    }
    
    init(identifier:String,latitude:Double,longitude:Double,radius:CLLocationDistance) {
        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius
        self.identifier = identifier
    }
    
    @objc required init?(coder aDecoder: NSCoder) {
        self.identifier = aDecoder.decodeObjectForKey("identifier") as! String
        self.latitude = aDecoder.decodeDoubleForKey("latitude")
        self.longitude = aDecoder.decodeDoubleForKey("longitude")
        self.radius = aDecoder.decodeDoubleForKey("radius")
        self.notifyOnEnter = aDecoder.decodeBoolForKey("notifyOnEnter")
        self.notifyOnExit = aDecoder.decodeBoolForKey("notifyOnExit")
    }
    
    @objc func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.identifier, forKey: "identifier")
        aCoder.encodeDouble(self.latitude, forKey: "latitude")
        aCoder.encodeDouble(self.longitude, forKey: "longitude")
        aCoder.encodeDouble(self.radius, forKey: "radius")
        aCoder.encodeBool(self.notifyOnEnter, forKey: "notifyOnEnter")
        aCoder.encodeBool(self.notifyOnExit, forKey: "notifyOnExit")
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        if object == nil {
            return false
        }
        
        if let _ = object as? L8Region {
            if object === self {
                return true
            }
            if object?.identifier == self.identifier {
                return true
            }
            return false
        }
        
        return false
    }
}

func == (left:L8Region,right:L8Region) ->Bool {
    return left.identifier == right.identifier
}

protocol LocationManagerDelegate{
    func locationManagerDidEnterRegion(manager:LocationManager,region:L8Region)->Void
    func locationManagerDidExitRegion(manager:LocationManager,region:L8Region)->Void
}



class LocationManager: NSObject,CLLocationManagerDelegate {
    
    var systemLocationManager:CLLocationManager!
    var delegate:LocationManagerDelegate?
    
    var monitorRegions:[L8Region] = []
    lazy var insideRegions:[L8Region] = {
        let path = self.pathForSaveInisdeRegion()
        let diskData = NSKeyedUnarchiver.unarchiveObjectWithFile(path!)
        if diskData != nil {
            return diskData as! [L8Region]
        }
        return []
    }()
    
    let queueForProcessMonitorRegion = dispatch_queue_create("QueueForProcessMonitorRegion", DISPATCH_QUEUE_CONCURRENT)
    let queueForProcessInsideRegion = dispatch_queue_create("QueueForProcessInsideRegion", DISPATCH_QUEUE_CONCURRENT)
    
    static let sharedLocationManager:LocationManager = {
       let manager = LocationManager()
        
        manager.systemLocationManager = CLLocationManager()
        manager.systemLocationManager.delegate = manager
        manager.systemLocationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager.systemLocationManager.distanceFilter = 100
        
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
        
        manager.systemLocationManager.startUpdatingLocation()
        
        NSNotificationCenter.defaultCenter().addObserver(manager, selector: "applicationWillResignActive", name: UIApplicationWillResignActiveNotification, object: nil)
        
        return manager
    }()
    
    
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .AuthorizedAlways:
            print("AuthorizedAlways")
            //self.systemLocationManager.startUpdatingLocation()
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
        
        let location = locations.first
        
        if dbStoreToBmob {
            if let bmUser = BmobUser.getCurrentUser() {
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
            L8SqlLite.sharedSqlite.addNewLocation((location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!)
        }
        
        dispatch_async(self.queueForProcessMonitorRegion) { () -> Void in
            for region in self.monitorRegions {
                if region.location.distanceFromLocation(location!) <= region.radius {
                    if region.notifyOnEnter && !self.isInsideRegion(region) {
                        self.delegate?.locationManagerDidEnterRegion(self, region: region)
                    }
                    self.addInsideRegion(region)
                }else{
                    if region.notifyOnExit && self.isInsideRegion(region) {
                        self.delegate?.locationManagerDidExitRegion(self, region: region)
                    }
                    self.removeInsideRegion(region)
                }
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    func addMonitorRegion(region:L8Region){
        dispatch_barrier_async(self.queueForProcessMonitorRegion) { () -> Void in
            if self.monitorRegions.contains(region) {
                return
            }
            self.monitorRegions.append(region)
            if let location = self.systemLocationManager.location {
                if region.notifyOnEnter && location.distanceFromLocation(region.location) <= region.radius {
                    self.delegate?.locationManagerDidEnterRegion(self, region: region)
                    self.addInsideRegion(region)
                }
            }
        }
    }
        
    func removeMonitorRegion(region:L8Region){
        dispatch_barrier_async(self.queueForProcessMonitorRegion) { () -> Void in
            if let index = self.monitorRegions.indexOf(region) {
                self.monitorRegions.removeAtIndex(index)
            }
        }
    }
    
    func isMonitoringRegion(region:L8Region) -> Bool {
        var result:Bool = false
        dispatch_sync(self.queueForProcessMonitorRegion) { () -> Void in
            if self.monitorRegions.contains(region) {
                result = true
            }
        }
        return result
    }
    
    private func addInsideRegion(region:L8Region){
        dispatch_barrier_async(self.queueForProcessInsideRegion) { () -> Void in
            if self.insideRegions.contains(region) {
                return
            }
            self.insideRegions.append(region)
        }
    }
    
    private func removeInsideRegion(region:L8Region){
        dispatch_barrier_async(self.queueForProcessInsideRegion) { () -> Void in
            if let index = self.insideRegions.indexOf(region) {
                self.insideRegions.removeAtIndex(index)
            }
        }
    }
    
    func isInsideRegion(region:L8Region) -> Bool {
        var result:Bool = false
        dispatch_sync(self.queueForProcessInsideRegion) { () -> Void in
            if self.insideRegions.contains(region) {
                result = true
            }
        }
        return result
    }
    
    private func pathForSaveInisdeRegion()->String?{
        
        if let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first {
            return (path as NSString).stringByAppendingPathComponent("TcbInsideRegions")
        }
        
        return nil
    }
    
    private func save(){
        let path = self.pathForSaveInisdeRegion()
        let fileManager = NSFileManager.defaultManager()
        if !fileManager.fileExistsAtPath(path!) {
            fileManager.createFileAtPath(path!, contents: nil, attributes: nil)
        }
        dispatch_barrier_async(self.queueForProcessInsideRegion) { () -> Void in
            NSKeyedArchiver.archiveRootObject(self.insideRegions, toFile: path!)
        };
    }
    
    func applicationWillResignActive(){
        self.save()
    }
}
