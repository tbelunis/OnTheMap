//
//  OTMStudentLocation.swift
//  OnTheMap
//
//  Created by TOM BELUNIS on 5/12/15.
//  Copyright (c) 2015 TOM BELUNIS. All rights reserved.
//

struct OTMStudentLocation {
    var firstName = ""
    var lastName = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var mediaURL = ""
    
    /* Construct a student location from a dictionary */
    init(dictionary: [String : AnyObject]) {
        firstName = dictionary[OTMClient.JSONResponseKeys.FirstName] as!String
        lastName = dictionary[OTMClient.JSONResponseKeys.LastName] as! String
        latitude = dictionary[OTMClient.JSONResponseKeys.Latitude] as! Double
        longitude = dictionary[OTMClient.JSONResponseKeys.Longitude] as! Double
        mediaURL = dictionary[OTMClient.JSONResponseKeys.MediaURL] as! String

    }
    
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
    
    /* Helper: Given an array of dictionaries, convert them to an array of OTMUser objects */
    static func studentLocationsFromResults(results: [[String : AnyObject]]) -> [OTMStudentLocation] {
        var users = [OTMStudentLocation]()
        
        for result in results {
            users.append(OTMStudentLocation(dictionary: result))
        }
        
        return users
    }
}
