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
    
    var locations = OTMStudentLocations.sharedInstance()
    var mapper: OTMMapper?
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addLocationButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var logoffButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mapView.mapType = .Standard
        mapView.delegate = self

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.setRightBarButtonItems([refreshButton, addLocationButton], animated: true)
        self.tabBarController?.navigationItem.setLeftBarButtonItem(logoffButton, animated: true)
        self.toolbar.hidden = true
        let mapTabBarItem = self.tabBarController?.tabBar.items?.first! as! UITabBarItem
        mapTabBarItem.selectedImage = UIImage(named: "map.pdf")
        let listTabBarItem = self.tabBarController?.tabBar.items?.last! as! UITabBarItem
        listTabBarItem.selectedImage = UIImage(named: "list.pdf")
        mapStudentLocations()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapStudentLocations() {
        // Use the client to get the student locations
        OTMClient.sharedInstance().getStudentLocations { locations, error in
            // Successfully got the locations, so add them to the map
            if let locations = locations as OTMStudentLocations? {
                self.locations = locations
                self.mapper = OTMMapper(viewController: self, mapView: self.mapView)
                self.mapper?.addPinsToMap(self.locations)
                self.mapper?.setCenterOfMapToStudentLocation(self.locations.first)
            } else {
                let alertController = UIAlertController.alertWithError("Error getting student locations", error: error!)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
    
    // Add location pin touched so present the information posting view
    @IBAction func addLocationTouch(sender: UIBarButtonItem) {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("InformationPostingView") as! UIViewController
        self.presentViewController(controller, animated: true, completion: nil)
    }

    // Log off from Udacity
    @IBAction func logoffButtonTouch(sender: UIBarButtonItem) {
        OTMClient.sharedInstance().logoffOfUdacity() { result, error in
            if let error = error {
                let alertController = UIAlertController.alertWithError("Error Logging Off", error: error)
                self.presentViewController(alertController, animated: true, completion: nil)
            } else {
                // User has logged off, so present the login screen
                dispatch_async(dispatch_get_main_queue(), {
                    let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LoginView") as! UIViewController
                    self.presentViewController(controller, animated: true, completion: nil)
                })
                
            }
        }
        
    }
    
    // Refresh the map with udpated student locations
    @IBAction func refreshButtonTouch(sender: UIBarButtonItem) {
        mapStudentLocations()
    }
}


