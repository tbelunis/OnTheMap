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
        // MARK: Parse API Key
        static let ApiKey = ""
        
        // MARK: URLs
        static let BaseUdacityURL: String = "https://www.udacity.com/api/"
        
    }
    
    struct Methods {
        
        // MARK: Authentication
        static let AuthenticationSessionNew = "session"
    }
    
    // MARK: JSON Body Keys
    struct JSONBodyKeys {
        static let Udacity = "udacity"
        static let Username = "username"
        static let Password = "password"
    }
    
    // MARK: JSON Response Keys
    struct JSONResponseKeys {
        static let Account = "account"
        static let Registered = "registered"
        static let Key = "key"
        static let Session = "session"
        static let ID = "id"
        static let Expiration = "expiration"
    }
}
