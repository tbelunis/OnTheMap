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
    var mapper: OTMMapper?
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addLocationButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var toolbar: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mapView.mapType = .Standard
        mapView.delegate = self
        self.tabBarController?.navigationItem.setRightBarButtonItems([refreshButton, addLocationButton], animated: true)
        self.toolbar.hidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        mapStudentLocations()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapStudentLocations() {
        OTMClient.sharedInstance().getStudentLocations { locations, error in
            if let locations = locations as [OTMStudentLocation]? {
                self.locations = locations
                self.mapper = OTMMapper(mapView: self.mapView)
                for location in self.locations {
                    self.mapper?.addPinToMap(location)                }
                self.mapper?.setCenterOfMapToStudentLocation(self.locations.first)
            } else {
                println(error)
            }
        }
    }
    
    @IBAction func addLocationTouch(sender: UIBarButtonItem) {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("InformationPostingView") as! UIViewController
        self.presentViewController(controller, animated: true, completion: nil)
    }

    @IBAction func refreshButtonTouch(sender: UIBarButtonItem) {
        mapStudentLocations()
    }
}


