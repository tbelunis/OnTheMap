//
//  OTMConstants.swift
//  OnTheMap
//
//  Created by TOM BELUNIS on 5/10/15.
//  Copyright (c) 2015 TOM BELUNIS. All rights reserved.
//

import UIKit

extension OTMClient {
    struct Constants {
        // MARK: Parse Keys
        static let ParseAppID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let ParseApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        
        // MARK: URLs
        static let BaseUdacityURL = "https://www.udacity.com/api/"
        static let BaseParseURL = "https://api.parse.com/1/classes/StudentLocation"
        static let UdacitySignupURL = "https://www.udacity.com/account/auth#!/signup"
        
        // MARK: Mapping Constants
        static let LatitudeDelta = 25.0
        static let LongitudeDelta = 25.0
        
        // MARK: HTTP Response Status Code Constants
        static let HttpResponseOk = 200
        // Consider anything in the following range as successful
        static let HttpSuccessRange = (200...299)
        static let HttpResponseForbidden = 403
        static let HttpResponseNotFound = 404
        
    }
    
    struct Methods {
        
        // MARK: Authentication
        static let AuthenticationSessionNew = "session"
        static let PublicUserData = "users/{id}"
    }
    
    // MARK: JSON Body Keys
    struct JSONBodyKeys {
        static let Udacity = "udacity"
        static let Username = "username"
        static let Password = "password"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let UniqueKey = "uniqueKey"
    }
    
    // MARK: JSON Response Keys
    struct JSONResponseKeys {
        // MARK: General
        static let Status = "status"
        static let Error = "error"
        
        // MARK: Authorization
        static let Account = "account"
        static let Registered = "registered"
        static let Key = "key"
        static let Session = "session"
        static let ID = "id"
        static let Expiration = "expiration"
        
        // MARK: Udacity User Data
        static let UdacityUser = "user"
        static let UdacityFirstName = "first_name"
        static let UdacityLastName = "last_name"
 
        // MARK: Student Location Data
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let UniqueKey = "uniqueKey"
        
        
    }
    
}
