//
//  OTMUser.swift
//  OnTheMap
//
//  Created by TOM BELUNIS on 5/13/15.
//  Copyright (c) 2015 TOM BELUNIS. All rights reserved.
//

struct OTMUser {
    var firstName: String!
    var lastName: String!
    
    init(dictionary: [String : AnyObject]) {
        self.firstName = dictionary[OTMClient.JSONResponseKeys.UdacityFirstName] as! String
        self.lastName = dictionary[OTMClient.JSONResponseKeys.UdacityLastName] as! String
    }
    
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
}
