//
//  MapViewController.swift
//  OnTheMap
//
//  Created by TOM BELUNIS on 5/12/15.
//  Copyright (c) 2015 TOM BELUNIS. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    var locations: [OTMStudentLocation] = [OTMStudentLocation]()
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mapView.mapType = .Standard
        mapView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        OTMClient.sharedInstance().getStudentLocations { locations, error in
            if let locations = locations {
                self.locations = locations
                for location in self.locations {
                    self.addPinToMapView(location)
                }
                self.setCenterOfMapToLocation(self.locations.first)
            } else {
                println(error)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setCenterOfMapToLocation(studentLocation: OTMStudentLocation?) {
        if let studentLocation = studentLocation {
            let span = MKCoordinateSpanMake(5.0, 5.0)
            let location = CLLocationCoordinate2DMake(studentLocation.latitude, studentLocation.longitude)
            let region = MKCoordinateRegionMake(location, span)
            mapView.setRegion(region, animated: true)
        }
    }

    func addPinToMapView(studentLocation: OTMStudentLocation) {
        let location = CLLocationCoordinate2DMake(studentLocation.latitude, studentLocation.longitude)
        let annotation = OTMAnnotation(coordinate: location, title: studentLocation.fullName, subtitle: studentLocation.mediaURL)
        mapView.addAnnotation(annotation)
    }

}
