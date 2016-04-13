//
//  L8SqlLite.swift
//  TrackMySelf
//
//  Created by Chuanxun on 16/4/11.
//  Copyright © 2016年 Leon. All rights reserved.
//

import Foundation
import UIKit

class L8SqlLite : NSObject{
    var db: COpaquePointer = nil
    var mapView:MKMapView?
    
    static let sharedSqlite:L8SqlLite = {
        let sqlite = L8SqlLite()
        return sqlite
    }()
    
    override init(){
        super.init()
        if  self.openDatabase("l8location.db") == true {
            
            self.createTable()
        }
    }
    
    func addNewLocation(latitude:Double,longitude:Double) {
        
        /*
        let arr = [1,2,4]
        // (((10+1) + 2) + 4)
        let brr = arr.reduce(10) { (preElement:Int, element:Int) -> Int in
        return preElement + element
        }
        
        print(brr)
        */
        
        if db != nil {

            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
            let timeString = dateFormatter.stringFromDate(NSDate())
            print("AddLocation:\(latitude,longitude)")
            let sqlString = "insert into locations(latitude,longitude,arriveTime) values('\(latitude)','\(longitude)','\(timeString)');"
            
            if sqlite3_exec(db, sqlString.cStringUsingEncoding(NSUTF8StringEncoding)!, nil, nil, nil) == SQLITE_OK {
                print("add to sqlite succeeded")
            }else {
                print("add to sqlite failed")
            }
            
            
        }
                
    }
    
    func loadLocations(fromTime:NSDate,toTime:NSDate) ->Void {
        
        if db != nil {
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
            let fromString = dateFormatter.stringFromDate(fromTime)
            let toString = dateFormatter.stringFromDate(toTime)
            
            var stmt: COpaquePointer = nil
            let sqlString = "select latitude,longitude,arriveTime from locations where arriveTime > '\(fromString)' and arriveTime <= '\(toString)';"
            
            if sqlite3_prepare_v2(db, sqlString.cStringUsingEncoding(NSUTF8StringEncoding)!, -1, &stmt, nil) == SQLITE_OK {
                
                var maxLatitude:CLLocationDegrees = -90
                var minLatitude:CLLocationDegrees = 90
                var maxLongitude:CLLocationDegrees = -180
                var minLongitude:CLLocationDegrees = 180
                var preCreateTime:NSDate? = nil
                var preCoordinate:CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
                
                while(sqlite3_step(stmt) == SQLITE_ROW) {
                  
                    let arriveTimeCString = UnsafePointer<CChar>(sqlite3_column_text(stmt, 2))
                    let arriveTimeString = String(CString: arriveTimeCString, encoding: NSUTF8StringEncoding)
                    let arriveTime = dateFormatter.dateFromString(arriveTimeString!)
                    
                    if preCreateTime == nil || arriveTime!.timeIntervalSinceDate(preCreateTime!) >= 60 {
                        let latitude = sqlite3_column_double(stmt, 0)
                        let longitude = sqlite3_column_double(stmt, 1)
                        print("LoadLocation:\(latitude,longitude)")
                        
                        let latitudeCStr = UnsafePointer<CChar>(sqlite3_column_text(stmt, 0))
                        let latitudeStr = String(CString: latitudeCStr, encoding: NSUTF8StringEncoding)
                        let longitudeCStr = UnsafePointer<CChar>(sqlite3_column_text(stmt, 1))
                        let longitudeStr = String(CString: longitudeCStr, encoding: NSUTF8StringEncoding)
                        let latitude2 = Double(latitudeStr!)
                        let longitude2 = Double(longitudeStr!)
                        print("LoadLocation2:\(latitude2,longitude2)")
                        let coordinate = CLLocationCoordinate2DMake(latitude2!, longitude2!)
                        
                        let annotation = L8Annotation(location: coordinate, date: arriveTime!)
                        self.mapView?.addAnnotation(annotation)
                        
                        if preCreateTime != nil {
                            let coordinateArray = (UnsafeMutablePointer<CLLocationCoordinate2D>)(malloc(2 * sizeof(CLLocationCoordinate2D)));
                            coordinateArray[0] = preCoordinate
                            coordinateArray[1] = coordinate
                            
                            let polyLine = MKPolyline(coordinates: coordinateArray, count: 2)
                            
                            self.mapView?.addOverlay(polyLine)
                            
                            free(coordinateArray)
                        }
                        
                        maxLatitude = max(maxLatitude,latitude)
                        minLatitude = min(minLatitude,latitude)
                        maxLongitude = max(maxLongitude,longitude)
                        minLongitude = min(minLongitude,longitude)
                        
                        preCreateTime = arriveTime
                        
                        preCoordinate = coordinate
                    }
                }
                
                if preCreateTime != nil {
                    let centerLatitude = (maxLatitude + minLatitude) / 2.0
                    let centerLongitude = (maxLongitude + minLongitude) / 2.0
                    let center = CLLocationCoordinate2DMake(centerLatitude, centerLongitude)
                    
                    let span = MKCoordinateSpanMake(maxLatitude - minLatitude + 0.1, maxLongitude - minLongitude + 0.1)
                    
                    let region = MKCoordinateRegionMake(center, span)
                    
                    self.mapView?.setRegion(region, animated: true)
                }
            }
            
        }
    }

    
    func openDatabase(dbName:String) ->Bool {
        
        var path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        path = (path as NSString).stringByAppendingPathComponent(dbName)
        
        let cpath = path.cStringUsingEncoding(NSUTF8StringEncoding)
        
        let error = sqlite3_open(cpath!,&db)
        
        if error != SQLITE_OK {
            print("failed to open db")
            sqlite3_close(db)
            return false
        }else {
            print("open db succeeded")
            return true
        }
        
    }
    
    func createTable() ->Bool {
        if db != nil {
            let sqlString = "create table if not exists locations(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,latitude varchar(32),longitude varchar(32),arriveTime varchar(32));"
            
            return sqlite3_exec(db, sqlString.cStringUsingEncoding(NSUTF8StringEncoding)!, nil, nil, nil) == SQLITE_OK
            
        }
        
        return false
    }
    
    deinit{
        sqlite3_close(db)
    }
    
    
}