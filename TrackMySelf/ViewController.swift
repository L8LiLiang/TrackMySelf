//
//  ViewController.swift
//  TrackMySelf
//
//  Created by Chuanxun on 16/3/28.
//  Copyright © 2016年 Leon. All rights reserved.
//

import UIKit


let RegSuccNotifi = "RegisterSuccessNotfi"

class ViewController: UIViewController,MKMapViewDelegate {

    @IBOutlet weak var lastTwoDay: UIButton!
    @IBOutlet weak var lastOneDay: UIButton!
    @IBOutlet weak var lastOneHour: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "registerSucceeded:", name: RegSuccNotifi, object: nil)
        mapView.delegate = self
        mapView.userTrackingMode = MKUserTrackingMode.FollowWithHeading
        mapView.showsUserLocation = true
        
        if let bmUser = BmobUser.getCurrentUser() {
//            let query = BmobUser.query()
//            query.whereKey("mobilePhoneNumber", equalTo: bmUser.mobilePhoneNumber)
//            query.findObjectsInBackgroundWithBlock({ (result, error) -> Void in
//                if let user:BmobUser? = result.first as? BmobUser {
//                    print(user?.objectForKey("password"))
            if let password = NSUserDefaults.standardUserDefaults().valueForKey(bmUser.mobilePhoneNumber) {
                    BmobUser.loginInbackgroundWithAccount(bmUser.mobilePhoneNumber, andPassword: password as! String) { (user, error) -> Void in
                        if user != nil {
                            self.loginButton.text(bmUser.mobilePhoneNumber)
                        }else{
                            print(error)
                        }
                    }
            }
//                }
//            })

        }
        
        L8SqlLite.sharedSqlite.mapView = self.mapView
        
        let dbStorePositionSwitch = UISwitch()
        dbStorePositionSwitch.on = false
        dbStorePositionSwitch.addTarget(self, action: "changeDbStorePosition:", forControlEvents: .ValueChanged)
        let rightItem = UIBarButtonItem(customView: dbStorePositionSwitch)
        self.navigationItem.rightBarButtonItem = rightItem
    }

    func changeDbStorePosition(sw:UISwitch){
        let userDefault = NSUserDefaults.standardUserDefaults()
        if sw.on {
            userDefault.setBool(true, forKey: "DbStoreToBmob")
        }else {
            userDefault.setBool(false, forKey: "DbStoreToBmob")
        }
        
        userDefault.synchronize()
    }
    
    func showLocations(fromTime:NSDate,toTime:NSDate){
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        
        let query = BmobQuery(className: "locations")
        
//        let fromString = dateFormatter.stringFromDate(fromTime)
//        let toString = dateFormatter.stringFromDate(toTime)
        
        query.whereKey("arriveTime", greaterThan: fromTime)
        query.whereKey("arriveTime", lessThanOrEqualTo: toTime)
        query.limit = 1000
        query.orderByAscending("arriveTime")
        
        query.findObjectsInBackgroundWithBlock { (result, error) -> Void in
            if error == nil && result.count > 0 {
                
                var maxLatitude:CLLocationDegrees = -90
                var minLatitude:CLLocationDegrees = 90
                var maxLongitude:CLLocationDegrees = -180
                var minLongitude:CLLocationDegrees = 180
                var preCreateTime:NSDate? = nil
                
                for i in 0..<result.count {
                    let object = result[i] as! BmobObject
                    
                    let createTime = object.objectForKey("arriveTime") as! NSDate
                    
                    if preCreateTime == nil || createTime.timeIntervalSinceDate(preCreateTime!) >= 60 {
                        
                        let latitude = object.objectForKey("latitude").doubleValue
                        let longitude = object.objectForKey("longitude").doubleValue
                        let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
                        
                        let annotation = L8Annotation(location: coordinate, date: createTime)
                        self.mapView.addAnnotation(annotation)
                        
                        maxLatitude = max(maxLatitude,latitude)
                        minLatitude = min(minLatitude,latitude)
                        maxLongitude = max(maxLongitude,longitude)
                        minLongitude = min(minLongitude,longitude)
                        
                        preCreateTime = createTime
                    }
                    
                }
                
                if preCreateTime != nil {
                    let centerLatitude = (maxLatitude + minLatitude) / 2.0
                    let centerLongitude = (maxLongitude + minLongitude) / 2.0
                    let center = CLLocationCoordinate2DMake(centerLatitude, centerLongitude)
                    
                    let span = MKCoordinateSpanMake(maxLatitude - minLatitude, maxLongitude - minLongitude)
                    
                    let region = MKCoordinateRegionMake(center, span)
                    
                    self.mapView.setRegion(region, animated: true)
                }
                
            }else {
                print(error)
            }
        }
    }

    @IBAction func oneHour(sender: AnyObject) {
        
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.removeOverlays(self.mapView.overlays)
        
        let fromTime = NSDate(timeIntervalSinceNow: -60*60)
        let toTime = NSDate()
        
        let userDef = NSUserDefaults.standardUserDefaults()
        let dbStoreToBmob = userDef.boolForKey("DbStoreToBmob")
        if  dbStoreToBmob {
            self.showLocations(fromTime, toTime: toTime)
        }else{
            L8SqlLite.sharedSqlite.loadLocations(fromTime, toTime: toTime)
        }
        
    }

    @IBAction func oneDay(sender: AnyObject) {
        
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.removeOverlays(self.mapView.overlays)
        
        let userDef = NSUserDefaults.standardUserDefaults()
        let dbStoreToBmob = userDef.boolForKey("DbStoreToBmob")
        if dbStoreToBmob {
            for i in 1...24 {
                let fromTime = NSDate(timeIntervalSinceNow: -Double(i)*60*60)
                let toTime = NSDate(timeIntervalSinceNow: -Double(i-1)*60*60)
                
                self.showLocations(fromTime, toTime: toTime)
            }
        }else{
            for i in 1...24 {
                let fromTime = NSDate(timeIntervalSinceNow: -Double(i)*60*60)
                let toTime = NSDate(timeIntervalSinceNow: -Double(i-1)*60*60)
                
               L8SqlLite.sharedSqlite.loadLocations(fromTime, toTime: toTime)
            }
        }
        
    }

    @IBAction func twoDay(sender: AnyObject) {
        
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.removeOverlays(self.mapView.overlays)
        
        let userDef = NSUserDefaults.standardUserDefaults()
        let dbStoreToBmob = userDef.boolForKey("DbStoreToBmob")
        
        if dbStoreToBmob {
            for i in 1...48 {
                let fromTime = NSDate(timeIntervalSinceNow: -Double(i)*60*60)
                let toTime = NSDate(timeIntervalSinceNow: -Double(i-1)*60*60)
                
                self.showLocations(fromTime, toTime: toTime)
            }
        }else{
            for i in 1...48 {
                let fromTime = NSDate(timeIntervalSinceNow: -Double(i)*60*60)
                let toTime = NSDate(timeIntervalSinceNow: -Double(i-1)*60*60)
                
                L8SqlLite.sharedSqlite.loadLocations(fromTime, toTime: toTime)
            }
        }

    }
    
    @IBAction func login(sender: AnyObject) {
        
        let loginController = LoginController()
        
        self.navigationController?.pushViewController(loginController, animated: true)
        
    }

    func registerSucceeded(notify:NSNotification){
        let userInfo = notify.userInfo as! [String:String]
        self.loginButton.text(userInfo["PhoneNumber"]!)
    }
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let _ = annotation as? MKUserLocation {
            return nil
        }
        
        if let annotationL8 = annotation as? L8Annotation {
            
            var view:L8AnnotationView? = mapView.dequeueReusableAnnotationViewWithIdentifier("l8annotationviewreuse") as? L8AnnotationView
            
            if view == nil {
                view = L8AnnotationView(annotation: annotationL8, reuseIdentifier: "l8annotationviewreuse")
                view?.canShowCallout = true
                view?.animatesDrop = true
                view?.pinColor = MKPinAnnotationColor.Green
            }
    
            return view
        }
        
        return nil
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        guard  let polyline = overlay as? MKPolyline else{
            return MKOverlayRenderer()
        }
        
        let render = MKPolylineRenderer(polyline: polyline)
        render.strokeColor = UIColor.brownColor()
        render.fillColor = UIColor.brownColor()
        render.lineWidth = 5
        render.lineJoin = CGLineJoin.Round
        
        return render
    }
    
    
    
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

