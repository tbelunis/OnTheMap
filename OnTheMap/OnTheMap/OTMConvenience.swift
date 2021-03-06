//
//  OTMConvenience.swift
//  OnTheMap
//
//  Created by TOM BELUNIS on 5/11/15.
//  Copyright (c) 2015 TOM BELUNIS. All rights reserved.
//

import Foundation
import UIKit

extension OTMClient {
    
    // Get the student locations from Parse
    func getStudentLocations(completionHandler: (result: OTMStudentLocations?, error: NSError?) -> Void) {
        taskForParseGETMethod() { JSONResult, error in
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                if let results = JSONResult?.valueForKey("results") as? [[String : AnyObject]] {
                    var locations = OTMStudentLocation.studentLocationsFromResults(results)
                    completionHandler(result: locations, error: nil)
                } else {
                    completionHandler(result: nil, error: NSError(domain: "getStudentLocations parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getStudentLocations"]))
                }
            }
        }
    }
    
    // Open the signup page on the Udacity site
    func openUdacitySignupPage() {
        openURLInSafari(NSURL(string: Constants.UdacitySignupURL)!)
    }
    
}
