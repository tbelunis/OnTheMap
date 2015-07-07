//
//  UIAlertExtensions.swift
//  OnTheMap
//
//  Created by TOM BELUNIS on 5/28/15.
//  Copyright (c) 2015 TOM BELUNIS. All rights reserved.
//

import UIKit

// Add methods to UIAlertController to build alerts from text strings and error objects
extension UIAlertController {
    class func alertWithError(title: String, error: NSError) -> UIAlertController {
      return alertWithMessage(title, message: error.localizedDescription)
    }
    
    class func alertWithMessage(title: String, message: String) -> UIAlertController {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        controller.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        return controller
    }
}
