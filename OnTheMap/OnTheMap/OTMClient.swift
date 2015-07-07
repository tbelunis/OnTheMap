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
    var isUserAuthenticated = false;
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    // Login to Udacity with username and passwor
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
            if error != nil {
                // Log in failed return error to caller
                completionHandler(result: false, error: error)
            } else {
                // Check the HTTP response to see if the request succeeded
                let httpResponse = self.checkHttpResponse(response)
                // If the HTTP request was not successful, return an error to the caller
                if !httpResponse.success {
                    self.isUserAuthenticated = false
                    completionHandler(result: false, error: NSError(domain: "Udacity Login", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey : "The username and/or password was incorrect. Please try again."]))
                } else {
                    // Request was successful, now parse the data that came back
                    var parsingError: NSError?
                    // Ignore the first five bytes of data returned by Udacity
                    let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
                    if let parsedResult = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as? [String :[String : AnyObject]] {
                        if let userID = parsedResult[JSONResponseKeys.Account]?[JSONResponseKeys.Key] as? String {
                            self.userID = userID
                            // We have the user id, so get the user data
                            self.getUdacityUserData(self.userID!) { result, error in
                                if let error = error {
                                    completionHandler(result: false, error: error)
                                } else {
                                    if let result = result {
                                        self.udacityUser = result
                                        self.isUserAuthenticated = true
                                        completionHandler(result: true, error: nil)
                                    }
                                }
                            }
                        } else {
                            // We couldn't find the user id, return an error to the caller
                            completionHandler(result: false, error: NSError(domain: "Udacity Login", code: -1, userInfo: [NSLocalizedDescriptionKey : "Error parsing data returned from Udacity"]))
                        }
                    }
                }
            }

        }
        
        task.resume()
        
        return task
    }
    
    // Logoff of Udacity and reset user id and session id to nil
    func logoffOfUdacity(completionHandler: (result: Bool, error: NSError?) -> Void) {
        let sessionURL = Constants.BaseUdacityURL + Methods.AuthenticationSessionNew
        let request = NSMutableURLRequest(URL: NSURL(string: sessionURL)!)
        request.HTTPMethod = "DELETE"
        
        // Find the XSRF-TOKEN cookie that is needed to log off from Udacity
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies as! [NSHTTPCookie] {
            if cookie.name == "XSRF-TOKEN" {
                xsrfCookie = cookie
            }
        }
        if let xsrfCookie = xsrfCookie {
            request.addValue(xsrfCookie.value!, forHTTPHeaderField: "X-XSRF-Token")
        }
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            // Set the following fields to nil so that the user will need to 
            // login again before using the app.
            self.sessionID = nil
            self.userID = nil
            self.udacityUser = nil
            if error != nil {
                completionHandler(result: false, error: error)
            } else {
                completionHandler(result: true, error: nil)
            }
        }
        
        task.resume()
    }
    
    // Method to process GET requests for Parse
    func taskForParseGETMethod(completionHandler:(result: AnyObject?, error: NSError?) -> Void) -> NSURLSessionDataTask  {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.addValue(Constants.ParseAppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ParseApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if let error = error {
                let newError = OTMClient.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: newError)
            } else {
                // Check the HTTP response status code
                let httpResponse = self.checkHttpResponse(response)
                if httpResponse.success {
                    // Success, so parse the JSON returned from Parse
                    OTMClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
                } else {
                    // HTTP request was not successful, so return an error to the caller
                    let httpResponseMessage = NSHTTPURLResponse.localizedStringForStatusCode(httpResponse.statusCode)
                    completionHandler(result: nil, error: NSError(domain: "Get Student Locations", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey : "The request could not be completed. \(httpResponseMessage)"]))
                }
            }
        }
        task.resume()
        
        return task
    }
    
    // Retrieve the data for the logged in user from Udacity
    func getUdacityUserData(userID: String, completionHandler: (result: OTMUser?, error: NSError?) -> Void) -> NSURLSessionDataTask {
        let sessionURL = Constants.BaseUdacityURL + OTMClient.subtituteKeyInMethod(Methods.PublicUserData, key: "id", value: userID)!
        let request = NSURLRequest(URL: NSURL(string: sessionURL)!)
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if let error = error {
                // Return an error to the caller
                let newError = OTMClient.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: newError)
            } else {
                // Check the HTTP response status code
                let httpResponse = self.checkHttpResponse(response)
                if !httpResponse.success {
                    // HTTP request was not successful, so return an error the caller
                    let httpResponseMessage = NSHTTPURLResponse.localizedStringForStatusCode(httpResponse.statusCode)
                    completionHandler(result: nil, error: NSError(domain: "getUdacityUserData", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey : "Could not get Udacity user data. Server returned \(httpResponseMessage)"]))
                } else {
                    // Request was successful, now parse the data that came back
                    var parsingError: NSError?
                    // Ignore the first five bytes of data returned by Udacity
                    let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
                    if let parsedResult = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as? [String : [String : AnyObject]] {
                        
                        var userData = OTMUser(dictionary: parsedResult[JSONResponseKeys.UdacityUser]!)
                    
                        completionHandler(result: userData, error: nil)
                    } else {
                        completionHandler(result: nil, error: NSError(domain: "getUdacityUserData parsing", code: 0, userInfo:  [NSLocalizedDescriptionKey: "Could not parse getUdacityUserData"]))
                    }
                }
            }
        }
        
        task.resume()
        
        return task
    }
    
    // POST the student location data to Parse
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
        request.addValue(Constants.ParseAppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ParseApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        var jsonifyError: NSError? = nil
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonBody, options: nil, error: &jsonifyError)
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if let error = error {
                // Return an error to the caller
                let newError = OTMClient.errorForData(data, response: response, error: error)
                completionHandler(result: false, error: newError)
            } else {
                // Check the HTTP response
                let httpResponse = self.checkHttpResponse(response)
                if httpResponse.success {
                    // Posted successfully
                    completionHandler(result: true, error: nil)
                } else {
                    // POST failed, return error to caller
                    let httpResponseMessage = NSHTTPURLResponse.localizedStringForStatusCode(httpResponse.statusCode)
                    completionHandler(result: false, error: NSError(domain: "postStudentLocation", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey : "Could not post student location. Server returned \(httpResponseMessage)"]))
                }
            }
        }
        
        task.resume()
    }
    
    // Open the URL in Safari
    // The URL has been validated before this function is called
    func openURLInSafari(url: NSURL) {
        UIApplication.sharedApplication().openURL(url)
    }
    
    // Use the HTTP HEAD request to validate a URL
    func validateURL(url: String, completionHandler: (result: Bool, error: NSError?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "HEAD"
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if let error = error {
                // Return error to caller
                let newError = OTMClient.errorForData(data, response: response, error: error)
                completionHandler(result: false, error: newError)
            } else {
                // Check to see if the HTTP request was successful
                let httpResponse = self.checkHttpResponse(response)
                if httpResponse.success {
                    // URL is valid, let the caller know
                    completionHandler(result: true, error: nil)
                } else {
                    // HTTP request failed, return an error to the user
                    let httpResponseMessage = NSHTTPURLResponse.localizedStringForStatusCode(httpResponse.statusCode)
                    completionHandler(result: false, error: NSError(domain: "Url Validation", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey : "The url is invalid. The server returned \(httpResponseMessage). Please check the url."]))
                }
            }
        }
        task.resume()
    }

    // Check the HTTP response, return a success flag and the status code
    func checkHttpResponse(response: NSURLResponse) -> (success: Bool, statusCode: Int) {
        // Cast response to NSHTTPURLResponse to get access to the status code
        let httpResponse: NSHTTPURLResponse = response as! NSHTTPURLResponse
        let statusCode = httpResponse.statusCode
        
        // Any status code within the range of 200 - 299 will be considered success
        let success = statusCode >= Constants.HttpSuccessRange.startIndex && statusCode <= Constants.HttpSuccessRange.endIndex
        return (success, statusCode)
    }
    
    // MARK: - Helpers
    // These helper methods were copied from code in the Udacity class "iOS Networking with Swift"
    
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
