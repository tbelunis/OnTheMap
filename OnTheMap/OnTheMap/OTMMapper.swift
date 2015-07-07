//
//  OTMMapper.swift
//  OnTheMap
//
//  Created by TOM BELUNIS on 5/22/15.
//  Copyright (c) 2015 TOM BELUNIS. All rights reserved.
//

import UIKit
import MapKit

// Handles the drawing of annotations on the map and 
// implements MKMapViewDelegate protocol methods to 
// handle the tapping on an annotation
class OTMMapper: NSObject {
    
    var mapView: MKMapView!
    var viewController: UIViewController!
    
    init(viewController: UIViewController, mapView: MKMapView) {
        super.init()
        self.viewController = viewController
        self.mapView = mapView
        self.mapView.delegate = self
    }
    
    // Add a pin to the map for a student location
    func addPinToMap(studentLocation: OTMStudentLocation) {
        // Get the location coordinates from latitude and longitude
        let location = CLLocationCoordinate2DMake(studentLocation.latitude, studentLocation.longitude)
        let annotation = OTMAnnotation(coordinate: location, title: studentLocation.fullName, subtitle: studentLocation.mediaURL)
        dispatch_async(dispatch_get_main_queue(), {
            self.mapView.addAnnotation(annotation)
        })
    }
    
    // Adds pins to the map for an OTMStudentLocations object
    func addPinsToMap(studentLocations: OTMStudentLocations) {
        var annotations = [OTMAnnotation]()
        for location in studentLocations {
            annotations.append(OTMAnnotation(coordinate: CLLocationCoordinate2DMake(location.latitude, location.longitude), title: location.fullName, subtitle: location.mediaURL))
        }
        dispatch_async(dispatch_get_main_queue(), {
            self.mapView.addAnnotations(annotations)
        })
    }
    
    // Set the center of the map to a given student location
    func setCenterOfMapToStudentLocation(studentLocation: OTMStudentLocation?) {
        if let studentLocation = studentLocation {
            // Create a CLLocationCoordinate2D object and pass it to 
            // setCenterOfMapToLocation(location: CLLocationCoordinate2D)
            let location = CLLocationCoordinate2DMake(studentLocation.latitude, studentLocation.longitude)
            setCenterOfMapToLocation(location)
        }
    }
    
    func setCenterOfMapToLocation(location: CLLocationCoordinate2D) {
        // Compute the span and region for the map
        let span = MKCoordinateSpanMake(OTMClient.Constants.LatitudeDelta, OTMClient.Constants.LongitudeDelta)
        let region = MKCoordinateRegionMake(location, span)
        setMapRegion(region)
    }
    
    // Set the map region on the mapView
    func setMapRegion(region: MKCoordinateRegion) {
        dispatch_async(dispatch_get_main_queue(), {
            self.mapView.setRegion(region, animated: true)
        })
    }
    
    func addAnnotation(annotation: MKAnnotation) {
        mapView.addAnnotation(annotation)
    }

}

// MARK: Implement the MKMapViewDelegate methods
extension OTMMapper: MKMapViewDelegate {
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        var view: MKPinAnnotationView! = nil
        
        if let annotation = annotation as? OTMAnnotation {
            let identifier = "pin"
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier("pin") as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.rightCalloutAccessoryView = UIButton.buttonWithType(.InfoLight) as! UIView
            }
            return view
        }
        return nil
    }
    
    // When the user taps on an annotation, check the URL and open it in Safari if it is valid
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        if let view = view {
            let annotation = view.annotation
            // Validate the URL that is in the annotation's subtitle
            OTMClient.sharedInstance().validateURL(annotation.subtitle!) { result, error in
                if let error = error {
                    // URL wasn't valid, so alert the user
                    let alertController = UIAlertController.alertWithError("Invalid URL", error: error)
                    self.viewController.presentViewController(alertController, animated: true, completion: nil)
                } else {
                    // URL was valid, so open it in Safari
                    OTMClient.sharedInstance().openURLInSafari(NSURL(string: annotation.subtitle!)!)
                }
            }
        }
    }
}


