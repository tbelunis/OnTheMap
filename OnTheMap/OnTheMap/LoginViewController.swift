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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Set the handlers on the text fields
        prepareTextField(emailTextField)
        prepareTextField(passwordTextField)
        
        // Disable login button until both an email and password are entered
        loginButton.enabled = false
        
        // Set up the activity indicator
        activityIndicator.hidden = true
        activityIndicator.hidesWhenStopped = true
    }

    // Set up the delegate for the text fields
    func prepareTextField(textField: UITextField) {
        textField.delegate = self
        textField.addTarget(self, action: "textFieldDidChange", forControlEvents: UIControlEvents.EditingChanged)
    }
    
    // Only enable the login button when both the username and password are entered
    func textFieldDidChange() {
        if !emailTextField.text.isEmpty && !passwordTextField.text.isEmpty {
            loginButton.enabled = true
        } else {
            loginButton.enabled = false
        }
    }

    @IBAction func loginButtonTouchUpInside(sender: UIButton) {
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        self.emailTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        
        // Use the client to login to Udacity
        let client = OTMClient.sharedInstance()
        client.loginToUdacity(emailTextField.text, password: passwordTextField.text) { result, error in
            self.activityIndicator.stopAnimating()
            
            // In case of an error alert the user
            if let error = error {
                dispatch_async(dispatch_get_main_queue(), {
                    self.activityIndicator.hidden = true
                })
                let alertController = UIAlertController.alertWithError("Error Logging In To Udacity", error: error)
                self.presentViewController(alertController, animated: true, completion: nil)
            } else {
                // Login was successful, so show the tab controller
                if client.isUserAuthenticated {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.hidden = true
                        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("ManagerNavigationController") as! UINavigationController
                        self.presentViewController(controller, animated: true, completion: nil)
                    })
                }
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.hidden = true
            })
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

