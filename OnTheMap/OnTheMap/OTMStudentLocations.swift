//
//  OTMStudentLocations.swift
//  OnTheMap
//
//  Created by TOM BELUNIS on 7/7/15.
//  Copyright (c) 2015 TOM BELUNIS. All rights reserved.
//

import Foundation
import UIKit

// Singleton object for holding the student locations
// Uses an array to store the student locations
class OTMStudentLocations {
    var studentLocations = [OTMStudentLocation]()

    // Property to expose the count property of the underlying array
    var count: Int {
        return studentLocations.count
    }
    
    // Property to return item at index 0 if it exists, otherwise nil
    var first: OTMStudentLocation? {
        return studentLocations.isEmpty ? nil : studentLocations[0]
    }
    
    // Allow users of this class to access the underlying array by index
    subscript(index: Int) -> OTMStudentLocation {
        return studentLocations[index]
    }
    
    // Empty the array
    func clear() {
        studentLocations = [OTMStudentLocation]()
    }
    
    // Adds a student location to the array
    func addStudentLocation(studentLocation: OTMStudentLocation) {
        studentLocations.append(studentLocation)
    }
    
    // Returns the singleton object
    class func sharedInstance() -> OTMStudentLocations {
        struct Singleton {
            static var sharedInstance = OTMStudentLocations()
        }
        return Singleton.sharedInstance
    }
}

// MARK:  Implement the SequenceType protocol
// Allows users of the class to iterator over the
// underlying array with for-in syntax
extension OTMStudentLocations: SequenceType {
    func generate() -> GeneratorOf<OTMStudentLocation> {
        var nextIndex: Int = 0
        
        return GeneratorOf<OTMStudentLocation> {
            if nextIndex >= self.studentLocations.count {
                return nil
            } else {
                return self.studentLocations[nextIndex++]
            }
        }
    }
}



