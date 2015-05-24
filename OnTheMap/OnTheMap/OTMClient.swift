//
//  OTMClient.swift
//  OnTheMap
//
//  Created by TOM BELUNIS on 5/10/15.
//  Copyright (c) 2015 TOM BELUNIS. All rights reserved.
//

import Foundation
import UIKit

class OTMClient: NSObject {
    /* Shared session */
    var session: NSURLSession
    
    
    /* Authentication state */
    var sessionID: String? = nil
    var userID: String? = nil
    var udacityUser: OTMUser? = nil
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    func loginToUdacity(username: String, password: String, completionHandler: (result: Bool, error: NSError?) -> Void) -> NSURLSessionDataTask {
        let sessionURL = Constants.BaseUdacityURL + Methods.AuthenticationSessionNew
        let request = NSMutableURLRequest(URL: NSURL(string: sessionURL)!)
        let jsonBody: [String : [String : AnyObject]] = [
            JSONBodyKeys.Udacity: [
                JSONBodyKeys.Username: username,
                JSONBodyKeys.Password: password
            ]
        ]
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        var jsonifyError: NSError? = nil
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonBody, options: nil, error: &jsonifyError)
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if let error = error {
                let newError = OTMClient.errorForData(data, response: response, error: error)
                completionHandler(result: false, error: newError)
            } else {
                var parsingError: NSError?
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
                 if let parsedResult = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.allZeros, error: &parsingError) as? [String : AnyObject] {
                    if let userID = parsedResult[JSONResponseKeys.Key] as? String {
                        self.userID = userID
                        self.getUdacityUserData(self.userID!) { result, error in
                            if let error = error {
                                completionHandler(result: false, error: error)
                            } else {
                                if let udacityUser = result {
                                    self.udacityUser = udacityUser
                                    completionHandler(result: true, error: nil)
                                } else {
                                    completionHandler(result: false, error: NSError(domain: "getUdacityUserData parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getUdacityUserData"]))
                                }
                            }
                        }
                    }
                    if let sessionID = parsedResult[JSONResponseKeys.Session] as? String {
                        self.sessionID = sessionID
                    }
                    completionHandler(result:true, error:nil)
                } else {
                    completionHandler(result: false, error: NSError(domain: "loginToUdacity parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse loginToUdacity data"]))
                }
                
            }
        }
        task.resume()
        
        return task
    }
    
    func taskForParseGETMethod(completionHandler:(result: AnyObject?, error: NSError?) -> Void) -> NSURLSessionDataTask  {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if let error = error {
                let newError = OTMClient.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: newError)
            } else {
                OTMClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            }
        }
        task.resume()
        
        return task
    }
    
    func getUdacityUserData(userID: String, completionHandler: (result: OTMUser?, error: NSError?) -> Void) -> NSURLSessionDataTask {
        let sessionURL = Constants.BaseUdacityURL + OTMClient.subtituteKeyInMethod(Methods.PublicUserData, key: "id", value: userID)!
        let request = NSURLRequest(URL: NSURL(string: sessionURL)!)
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if let error = error {
                let newError = OTMClient.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: newError)
            } else {
                var parsingError: NSError?
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
                if let parsedResult = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as? [String : AnyObject] {
                    
                    var userData = OTMUser(dictionary: parsedResult)
                    
                    completionHandler(result: userData, error: nil)
                } else {
                    completionHandler(result: nil, error: NSError(domain: "getUdacityUserData parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getUdacityUserData"]))
                }
            }
        }
        
        task.resume()
        
        return task
    }
    
    func postStudentLocation(mapString: String, mediaUrl: String, latitude: Double, longitude: Double, completionHandler: (result: Bool, error: NSError?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: Constants.BaseParseURL)!)
        let user = udacityUser!
        let firstName = user.firstName!
        let lastName = user.lastName!
        let id = userID!
        
        let jsonBody: [String : AnyObject] = [
            JSONBodyKeys.UniqueKey : id,
            JSONBodyKeys.FirstName :firstName,
            JSONBodyKeys.LastName : lastName,
            JSONBodyKeys.MapString : mapString,
            JSONBodyKeys.MediaURL : mediaUrl,
            JSONBodyKeys.Latitude : latitude,
            JSONBodyKeys.Longitude : longitude
        ]
        
        request.HTTPMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        var jsonifyError: NSError? = nil
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonBody, options: nil, error: &jsonifyError)
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if let error = error {
                let newError = OTMClient.errorForData(data, response: response, error: error)
                completionHandler(result: false, error: newError)
            } else {
                completionHandler(result: true, error: nil)
            }
        }
        
        task.resume()
    }
    
    func openURLInSafari(url: NSURL) {
        if !UIApplication.sharedApplication().openURL(url) {
            println("bad url")
        }
    }
    
    func validateURL(url: String, completionHandler: (result: Bool, error: NSError?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "HEAD"
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if let error = error {
                let newError = OTMClient.errorForData(data, response: response, error: error)
                completionHandler(result: false, error: newError)
            } else {
                completionHandler(result: true, error: nil)
            }
        }
        task.resume()
    }
    
    // MARK: - Helpers
    
    /* Helper: Substitute the key for the value that is contained within the method name */
    class func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }
    
    /* Helper: Given a response with error, see if a status_message is returned, otherwise return the previous error */
    class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {
        
        if let parsedResult = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil) as? [String : AnyObject] {
            
            if let errorMessage = parsedResult[OTMClient.JSONResponseKeys.Error] as? String {
                
                let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                
                return NSError(domain: "OTM Error", code: 1, userInfo: userInfo)
            }
        }
        
        return error
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsingError: NSError? = nil
        
        let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
        
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
    }
    
    class func sharedInstance() -> OTMClient {
        struct Singleton {
            static var sharedInstance = OTMClient()
        }
        
        return Singleton.sharedInstance
    }
}
