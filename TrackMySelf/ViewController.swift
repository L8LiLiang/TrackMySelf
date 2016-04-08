//
//  ViewController.swift
//  TrackMySelf
//
//  Created by Chuanxun on 16/3/28.
//  Copyright © 2016年 Leon. All rights reserved.
//

import UIKit


let RegSuccNotifi = "RegisterSuccessNotfi"

class ViewController: UIViewController {

    @IBOutlet weak var lastTwoDay: UIButton!
    @IBOutlet weak var lastOneDay: UIButton!
    @IBOutlet weak var lastOneHour: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var loginButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "registerSucceeded:", name: RegSuccNotifi, object: nil)
        
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
        
    }


    @IBAction func oneHour(sender: AnyObject) {
        
        
        
    }

    @IBAction func oneDay(sender: AnyObject) {
    }

    @IBAction func twoDay(sender: AnyObject) {
    }
    
    @IBAction func login(sender: AnyObject) {
        
        let loginController = LoginController()
        
        self.navigationController?.pushViewController(loginController, animated: true)
        
    }

    func registerSucceeded(notify:NSNotification){
        let userInfo = notify.userInfo as! [String:String]
        self.loginButton.text(userInfo["PhoneNumber"]!)
    }
    
    @IBAction func read(sender: AnyObject) {
        
        let query = BmobQuery(className: "locations")
        query.limit = 100
        query.findObjectsInBackgroundWithBlock { (result, error) -> Void in
            print("find \(result.count) record")
            for obj in result as! [BmobObject] {
                print(obj.objectForKey("location"))
            }
        }
        
    }
    @IBAction func add(sender: AnyObject) {
        for i in 1...10 {
            let object = BmobObject(className: "locations")
            object.setObject(i*10, forKey: "location")
            
            
            let acl = BmobACL()
            acl.setWriteAccessForUser(BmobUser.getCurrentUser())
            acl.setReadAccessForUser(BmobUser.getCurrentUser())
            
            object.ACL = acl
            
            object.saveInBackground()
        }
    }
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

