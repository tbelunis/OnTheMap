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
        static let ParseAppID = "ENTER_PARSE_APP_ID_HERE"
        static let ParseApiKey = "ENTER_PARSE_API_KEY_HERE"
        
        // MARK: URLs
        static let BaseUdacityURL = "https://www.udacity.com/api/"
        static let BaseParseURL = "https://api.parse.com/1/classes/StudentLocation"
        static let UdacitySignupURL = "https://www.tbelunis.com/index.html"
        
        // MARK: Mapping Constants
        static let LatitudeDelta = 25.0
        static let LongitudeDelta = 25.0
        
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
