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
    static func studentLocationsFromResults(results: [[String : AnyObject]]) -> OTMStudentLocations {
        var users = OTMStudentLocations.sharedInstance()
        users.clear()
        for result in results {
            if isValidDictionaryForStudentLocation(result) {
                users.addStudentLocation(OTMStudentLocation(dictionary: result))
            }
        }
        
        return users
    }
    
    /* Make sure that the dictionary has all the necessary entries for creating an OTMStudentLocation */
    static func isValidDictionaryForStudentLocation(dictionary: [ String : AnyObject]) -> Bool {
        return dictionary.indexForKey(OTMClient.JSONResponseKeys.FirstName) != nil &&
               dictionary.indexForKey(OTMClient.JSONResponseKeys.LastName) != nil &&
               dictionary.indexForKey(OTMClient.JSONResponseKeys.Latitude) != nil &&
               dictionary.indexForKey(OTMClient.JSONResponseKeys.Longitude) != nil &&
               dictionary.indexForKey(OTMClient.JSONResponseKeys.MediaURL) != nil
    }
}
