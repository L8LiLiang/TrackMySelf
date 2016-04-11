//
//  L8Annotation.swift
//  TrackMySelf
//
//  Created by Chuanxun on 16/4/11.
//  Copyright © 2016年 Leon. All rights reserved.
//

import UIKit

class L8Annotation: NSObject,MKAnnotation {

    var coordinate:CLLocationCoordinate2D
    var title:String?
    var subTitle:String
    
    init(location:CLLocationCoordinate2D,date:NSDate) {
        self.coordinate = location
        self.subTitle = "\(location.longitude,location.latitude)"
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyy-MM-dd hh:mm:ss"
        self.title = dateFormatter.stringFromDate(date)
        
    }
}
