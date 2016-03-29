//
//  VerifySmsCodeController.swift
//  TrackMySelf
//
//  Created by Chuanxun on 16/3/28.
//  Copyright © 2016年 Leon. All rights reserved.
//

import UIKit

class VerifySmsCodeController: UIViewController,CXTimerProtocol {
    
    var phoneNumberTextField:UITextField!
    var getSmsCodeButton:UIButton!
    var smsCodeTextField:UITextField!
    var verifySmsButton:UIButton!
    
    var passwordTextField:UITextField!
    
    override func loadView() {
        self.view = UIView()
        self.view.backgroundColor = UIColor.whiteColor()
        
        let phoneNumber = UITextField()
        let getSmsCodeBtn = UIButton()
        let verifySmsBtn = UIButton()
        let smsCodeTF = UITextField()
        
        phoneNumber.keyboardType = .NumberPad
        smsCodeTF.keyboardType = .NumberPad
        
        self.phoneNumberTextField = phoneNumber
        self.getSmsCodeButton = getSmsCodeBtn
        self.smsCodeTextField = smsCodeTF
        self.verifySmsButton = verifySmsBtn
        self.passwordTextField = UITextField()
        self.passwordTextField.keyboardType = .NumberPad
        
        self.view.sv(
            phoneNumber.placeholder("PhoneNumber").style({ (textField) -> () in
                textField.borderStyle = .RoundedRect
                textField.font = UIFont(name: "HelveticaNeue-Light", size: 16)
            }),
            smsCodeTF.placeholder("SmsCode").style({ (textField) -> () in
                textField.borderStyle = .RoundedRect
                textField.font = UIFont(name: "HelveticaNeue-Light", size: 16)
            }),
            getSmsCodeBtn.text("GetSmsCode").style({ (button) -> () in
                button.backgroundColor = UIColor.lightGrayColor()
            }).tap(getSmsCode),
            verifySmsBtn.text("VefifySmsCode").style({ (button) -> () in
                button.backgroundColor = UIColor.brownColor()
            }).tap(register),
            self.passwordTextField.placeholder("password").style({ (textField) -> () in
                textField.borderStyle = .RoundedRect
                textField.font = UIFont(name: "HelveticaNeue-Light", size: 16)
            })
        )
        
        self.view.layout(
            100,
            |-16-phoneNumber.width(200)-8-getSmsCodeBtn-|,
            16,
            |-16-smsCodeTF,
            16,
            |-16-self.passwordTextField,
            16,
            |-16-verifySmsBtn.width(200)
        )
        
        equalSizes(self.phoneNumberTextField,self.smsCodeTextField,self.passwordTextField)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.phoneNumberTextField.addTarget(self, action: "editChanged:", forControlEvents: .EditingChanged)
        self.smsCodeTextField.addTarget(self, action: "editChanged:", forControlEvents: .EditingChanged)
        self.passwordTextField.addTarget(self, action: "editChanged:", forControlEvents: .EditingChanged)
        
        self.title = "VerifySmsCode"
        
        self.getSmsCodeButton.enabled = false
        self.verifySmsButton.enabled = false
    }
    
    func getSmsCode(){
        print("getSmsCode")
        self.getSmsCodeButton.enabled = false
        CXTimer.sharedInstance().addTimerWithIdentifier("GetSmsCode", interval: 60, delegate: self)
        let phoneNumber = self.phoneNumberTextField.text
        BmobSMS.requestSMSCodeInBackgroundWithPhoneNumber(phoneNumber, andTemplate: "verifycode") { (result, error) -> Void in
            if error == nil {
                print("获取验证码成功 \(result)")
            }else{
                print(error)
            }
        }
    }

    func verifySmsCode(){
        print("verifySmsCode")
        
        BmobSMS.verifySMSCodeInBackgroundWithPhoneNumber(self.phoneNumberTextField.text, andSMSCode: self.smsCodeTextField.text) { (isSuccessful, error) -> Void in
            if error == nil {
                let regVc = RegisterController()
                regVc.phoneNumber = self.phoneNumberTextField.text
                self.navigationController?.pushViewController(regVc, animated: true)
            }else{
                print(error)
            }
        }
        
    }
    
    func register(){
        
        let bmUser = BmobUser()
        bmUser.mobilePhoneNumber = self.phoneNumberTextField.text
        bmUser.password = self.passwordTextField.text
        bmUser.signUpOrLoginInbackgroundWithSMSCode(self.smsCodeTextField.text) { (isSuccessful, error) -> Void in
            if isSuccessful {
                let notify = NSNotification(name: RegSuccNotifi, object: nil, userInfo: ["PhoneNumber":self.phoneNumberTextField.text!])
                NSNotificationCenter.defaultCenter().postNotification(notify)
                NSUserDefaults.standardUserDefaults().setValue(self.passwordTextField.text, forKey: self.phoneNumberTextField.text!)
                self.navigationController?.popToRootViewControllerAnimated(false)
            }else{
                print(error)
            }
        }
    }
    
    func editChanged(sender:UITextField){

        if self.phoneNumberTextField.text?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
            self.getSmsCodeButton.enabled = true
        }else{
            self.getSmsCodeButton.enabled = false
        }

        if self.phoneNumberTextField.text?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 && self.smsCodeTextField.text?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0
            && self.passwordTextField.text?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0
        {
            self.verifySmsButton.enabled = true
        }else{
            self.verifySmsButton.enabled = false
        }
   
    }
    
    func cxtimer(timer: CXTimer!, pass passedTime: NSTimeInterval, remain remainTime: NSTimeInterval) {
        self.getSmsCodeButton.text("\(remainTime)")
    }
    
    func cxtimerFired(timer: CXTimer!) {
        self.getSmsCodeButton.enabled = true
    }
}
