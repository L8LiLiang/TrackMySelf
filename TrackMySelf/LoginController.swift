//
//  LoginController.swift
//  TrackMySelf
//
//  Created by Chuanxun on 16/3/28.
//  Copyright © 2016年 Leon. All rights reserved.
//

import UIKit

class LoginController: UIViewController {

    var userNameTextField:UITextField!
    var passwordTextField:UITextField!
    var loginButton:UIButton!
    var regButton:UIButton!
    
    override func loadView() {
        self.view = UIView()
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.userNameTextField = UITextField()
        self.passwordTextField = UITextField()
        self.loginButton = UIButton()
        self.regButton = UIButton()
        
        self.userNameTextField.keyboardType = .NumberPad
        self.passwordTextField.keyboardType = .NumberPad
        
        self.view.sv(
        
            self.userNameTextField.placeholder("UserName or PhoneNumber").style({ (tf) -> () in
                tf.borderStyle = .RoundedRect
                
            }),
            self.passwordTextField.placeholder("password").style({ (tf) -> () in
                tf.borderStyle = .RoundedRect
            }),
            self.loginButton.text("login").style({ (btn) -> () in
                btn.backgroundColor = UIColor.brownColor()
            }).tap(login),
            self.regButton.text("register").style({ (btn) -> () in
                btn.backgroundColor = UIColor.brownColor()
            }).tap(register)
        )
        
        self.view.layout(
        
            100,
            self.userNameTextField.centerHorizontally(),
            8,
            self.passwordTextField.centerHorizontally(),
            8,
            self.loginButton.width(100),
            8,
            self.regButton.width(100)
        )
        alignVertically(self.userNameTextField,self.loginButton,self.regButton)
        equalSizes(self.userNameTextField,self.passwordTextField)
        equalSizes(self.loginButton,self.regButton)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userNameTextField.addTarget(self, action: "editChanged:", forControlEvents: .EditingChanged)
        self.passwordTextField.addTarget(self, action: "editChanged:", forControlEvents: .EditingChanged)
        
        self.loginButton.enabled = false
    }
    
    
    func editChanged(sender:UITextField){
        if self.userNameTextField.text?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 &&
            self.passwordTextField.text?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
                self.loginButton.enabled = true
        }else{
            self.loginButton.enabled = false
        }
    }
    
    func register(){
        let verifySmsVC = VerifySmsCodeController()
        self.navigationController?.pushViewController(verifySmsVC, animated: true)
    }
    
    func login(){
        BmobUser.loginInbackgroundWithAccount(self.userNameTextField.text, andPassword: self.passwordTextField.text) { (user, error) -> Void in
            if user != nil {
                
                let notify = NSNotification(name: RegSuccNotifi, object: nil, userInfo: ["PhoneNumber":self.userNameTextField.text!])
                NSNotificationCenter.defaultCenter().postNotification(notify)
                NSUserDefaults.standardUserDefaults().setValue(self.passwordTextField.text, forKey: self.userNameTextField.text!)
                self.navigationController?.popToRootViewControllerAnimated(false)
                
            }else{
                print(error)
            }
        }
    }
}
