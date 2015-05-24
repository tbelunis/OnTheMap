//
//  OTMMapper.swift
//  OnTheMap
//
//  Created by TOM BELUNIS on 5/22/15.
//  Copyright (c) 2015 TOM BELUNIS. All rights reserved.
//

import UIKit
import MapKit

class OTMMapper: NSObject {
    
    var mapView: MKMapView!
    
    init(mapView: MKMapView) {
        super.init()
        self.mapView = mapView
        self.mapView.delegate = self
    }
    
    func addPinToMap(studentLocation: OTMStudentLocation) {
        let location = CLLocationCoordinate2DMake(studentLocation.latitude, studentLocation.longitude)
        let annotation = OTMAnnotation(coordinate: location, title: studentLocation.fullName, subtitle: studentLocation.mediaURL)
        mapView.addAnnotation(annotation)
    }
    
    func setCenterOfMapToStudentLocation(studentLocation: OTMStudentLocation?) {
        if let studentLocation = studentLocation {
            let location = CLLocationCoordinate2DMake(studentLocation.latitude, studentLocation.longitude)
            setCenterOfMapToLocation(location)
        }
    }
    
    func setCenterOfMapToLocation(location: CLLocationCoordinate2D) {
        let span = MKCoordinateSpanMake(OTMClient.Constants.LatitudeDelta, OTMClient.Constants.LongitudeDelta)
        let region = MKCoordinateRegionMake(location, span)
        mapView.setRegion(region, animated: true)
    }
    
    func setCenterOfMapToLocation(location: CLLocationCoordinate2D, latitudinalMeters: CLLocationDistance, longitudinalMeters: CLLocationDistance) {
        let region = MKCoordinateRegionMakeWithDistance(location, latitudinalMeters, longitudinalMeters)
        mapView.setRegion(region, animated: true)
    }
    
    func addAnnotation(annotation: MKAnnotation) {
        mapView.addAnnotation(annotation)
    }
    
    func buttonClicked(sender: UIButton) {
        println("Annotation clicked")
    }
}

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
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        if let view = view {
            let annotation = view.annotation
            OTMClient.sharedInstance().validateURL(annotation.subtitle!) { result, error in
                if let error = error {
                    println("Invalid URL")
                } else {
                    OTMClient.sharedInstance().openURLInSafari(NSURL(string: annotation.subtitle!)!)
                }
            }
        }
    }
}
