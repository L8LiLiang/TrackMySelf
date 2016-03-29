//
//  RegisterController.swift
//  TrackMySelf
//
//  Created by Chuanxun on 16/3/28.
//  Copyright © 2016年 Leon. All rights reserved.
//

import UIKit

class RegisterController: UIViewController {

    
    var phoneNumberTextField:UITextField!
    var passwordTextField:UITextField!
    var smsTextField:UITextField!
    var registerButton:UIButton!
    
    var phoneNumber:String?
    var smsCode:String?
    
    override func loadView() {
        self.view = UIView()
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.phoneNumberTextField = UITextField()
        self.passwordTextField = UITextField()
        self.registerButton = UIButton()
        self.smsTextField = UITextField()
        
        self.phoneNumberTextField.keyboardType = .NumberPad
        self.passwordTextField.keyboardType = .NumberPad
        self.smsTextField.keyboardType = .NumberPad
        
        self.view.sv(
            self.phoneNumberTextField.placeholder("PhoneNumber").style({ (tf) -> () in
                tf.borderStyle = .RoundedRect
                tf.font = UIFont(name: "HelveticaNeue-Light", size: 16)
            }),
            self.passwordTextField.placeholder("Password").style({ (tf) -> () in
                tf.borderStyle = .RoundedRect
                tf.font = UIFont(name: "HelveticaNeue-Light", size: 16)
            }),
            self.registerButton.text("Register").style({ (btn) -> () in
                btn.backgroundColor = UIColor.brownColor()
            }),
            self.smsTextField.placeholder("SmsCode").style({ (tf) -> () in
                tf.borderStyle = .RoundedRect
                tf.font = UIFont(name: "HelveticaNeue-Light", size: 16)
            })
        )
        
        self.view.layout(
            100,
            self.phoneNumberTextField.centerHorizontally().width(200),
            8,
            self.passwordTextField.centerHorizontally().width(200),
            8,
            self.smsTextField.centerHorizontally().width(200),
            8,
            self.registerButton.centerHorizontally().width(100)
        )
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.registerButton.addTarget(self, action: "register:", forControlEvents: .TouchUpInside)
        
        self.phoneNumberTextField.addTarget(self, action: "editChanged:", forControlEvents: .EditingChanged)
        self.passwordTextField.addTarget(self, action: "editChanged:", forControlEvents: .EditingChanged)
        self.smsTextField.addTarget(self, action: "editChanged:", forControlEvents: .EditingChanged)
        
        self.title = "Register"
        
        self.phoneNumberTextField.text = self.phoneNumber
        
        self.registerButton.enabled = false
    }
    
    func register(sender:UIButton){
        
        let bmUser = BmobUser()
        bmUser.mobilePhoneNumber = self.phoneNumber
        bmUser.password = self.passwordTextField.text
        bmUser.signUpOrLoginInbackgroundWithSMSCode(self.smsTextField.text) { (isSuccessful, error) -> Void in
            if isSuccessful {
                let notify = NSNotification(name: RegSuccNotifi, object: nil, userInfo: ["PhoneNumber":self.phoneNumber!])
                NSNotificationCenter.defaultCenter().postNotification(notify)
                
                self.navigationController?.popToRootViewControllerAnimated(false)
            }else{
                print(error)
            }
        }
    }
    
    func editChanged(sender:UITextField){
        
        if self.phoneNumberTextField.text?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 && self.passwordTextField.text?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0
        && self.smsTextField.text?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0{
            self.registerButton.enabled = true
        }else{
            self.registerButton.enabled = false
        }
        
    }
}
