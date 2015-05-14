//
//  ViewController.swift
//  OnTheMap
//
//  Created by TOM BELUNIS on 5/10/15.
//  Copyright (c) 2015 TOM BELUNIS. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Set the handlers on the text fields
        prepareTextField(emailTextField)
        prepareTextField(passwordTextField)
        
        // Disable login button until both an email and password are entered
        loginButton.enabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func prepareTextField(textField: UITextField) {
        textField.delegate = self
        textField.addTarget(self, action: "textFieldDidChange", forControlEvents: UIControlEvents.EditingChanged)
    }
    
    func textFieldDidChange() {
        if !emailTextField.text.isEmpty && !passwordTextField.text.isEmpty {
            loginButton.enabled = true
        } else {
            loginButton.enabled = false
        }
    }

    @IBAction func loginButtonTouchUpInside(sender: UIButton) {
        self.emailTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        
        let client = OTMClient.sharedInstance()
        client.loginToUdacity(emailTextField.text, password: passwordTextField.text) { result, error in
            if let error = error {
                let alertController = UIAlertController(title: "Login Failed", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                self.presentViewController(alertController, animated: true, completion: nil)
            } else {
                let controller = self.storyboard!.instantiateViewControllerWithIdentifier("ManagerNavigationController") as! UINavigationController
                self.presentViewController(controller, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func signUpButtonTouch(sender: UIButton) {
        OTMClient.sharedInstance().openUdacitySignupPage()
    }
}

// MARK: UITextFieldDelegateMethods
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.passwordTextField {
            textField.resignFirstResponder()
        } else {
            self.passwordTextField.becomeFirstResponder()
        }
        return true
    }
}

