//
//  InformationPostingViewController.swift
//  OnTheMap
//
//  Created by TOM BELUNIS on 5/20/15.
//  Copyright (c) 2015 TOM BELUNIS. All rights reserved.
//

import UIKit
import MapKit

class InformationPostingViewController: UIViewController {
    
    var mapper: OTMMapper!
    var locationCoordinates: CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    @IBOutlet weak var locationPromptLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var submitInformationButton: UIButton!
    @IBOutlet weak var locationTextFieldView: UIView!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var findOnTheMapButton: UIButton!
    @IBOutlet weak var urlTextFieldView: UIView!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // Bring the location entry widgets into view
        locationPromptLabel.hidden = false
        locationTextFieldView.hidden = false
        locationTextField.hidden = false
        locationTextField.delegate = self
        findOnTheMapButton.hidden = false
        findOnTheMapButton.hidden = false
        
        // Hide the map and the link field
        mapView.hidden = true
        submitInformationButton.hidden = true
        urlTextFieldView.hidden = true
        urlTextField.delegate = self
        
        activityIndicator.hidden = true
        activityIndicator.hidesWhenStopped = true
        
        // Round the corners of the button
        findOnTheMapButton.layer.cornerRadius = 8
        findOnTheMapButton.contentEdgeInsets = UIEdgeInsetsMake(4, 10, 4, 10)
        submitInformationButton.layer.cornerRadius = 8
        cancelButton.layer.cornerRadius = 8
        
        // Build up the "Where are you studying today string?"
        var line2: NSAttributedString = NSAttributedString(string: "")
        
        if let font1 = UIFont(name: "Roboto-Thin", size: 20) {
            let attributes: [String : AnyObject] = [
                NSFontAttributeName: font1
            ]
            let line1 = NSAttributedString(string: "Where are you\n", attributes: attributes)
            if let font2 = UIFont(name: "Roboto-Medium", size: 20) {
                let attributes2 = [
                    NSFontAttributeName: font2
                ]
                line2 = NSAttributedString(string: "studying\n", attributes: attributes2)
            }
            let line3 = NSAttributedString(string: "today?", attributes: attributes)
            
            var str: NSMutableAttributedString  = NSMutableAttributedString(attributedString: line1)
            str.appendAttributedString(line2)
            str.appendAttributedString(line3)
            
            locationPromptLabel.attributedText = str
        }
    }
    
    // Post the entered information to Parse
    @IBAction func submitInformationButtonTouch(sender: UIButton) {
        activityIndicator.startAnimating()
        
        // First make sure the link is a valid URL
        OTMClient.sharedInstance().validateURL(urlTextField.text) { result, error in
            if let error = error {
                // Link was not valid, alert the user
                dispatch_async(dispatch_get_main_queue(), {
                    self.activityIndicator.stopAnimating()
                    let alertController = UIAlertController.alertWithMessage("Invalid URL entered", message: "Please check the URL you entered.")
                    self.presentViewController(alertController, animated: true, completion: nil)
                })
            } else {
                // The link was valid, so post the student location data
                OTMClient.sharedInstance().postStudentLocation(self.locationTextField.text, mediaUrl: self.urlTextField.text, latitude: self.locationCoordinates.latitude, longitude: self.locationCoordinates.longitude) { result, error in
                    if let error = error {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.activityIndicator.stopAnimating()
                        })
                        let alertController = UIAlertController.alertWithError("Error posting student location", error: error)
                        self.presentViewController(alertController, animated: true, completion: nil)
                    } else {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                }
            }
        }
    }

    // Attempt to geocode the location entered by the user
    @IBAction func findOnTheMapButtonTouch(sender: UIButton) {
        dispatch_async(dispatch_get_main_queue(), {
            self.activityIndicator.hidden = false
            self.activityIndicator.startAnimating()
        })

        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(locationTextField.text) { placemarks, error in
            if let error = error {
                // Geocoding failed, aler the user
                let alertController = UIAlertController.alertWithMessage("Geocoding Failed", message: "The geocoder could not code the location you entered. Please try a different location.")
                self.presentViewController(alertController, animated: true, completion: nil)
            } else {
                // Geocoding succeeded, so display the user's location on the map and prompt for a link
                if let placemarks = placemarks {
                    self.showMapAndUrlViews()
                    self.mapper = OTMMapper(viewController: self, mapView: self.mapView)
                    let placemark = placemarks[0] as! CLPlacemark
                    let location = placemark.location
                    let coords = location.coordinate
                    self.locationCoordinates = location.coordinate
                    let annotation = OTMAnnotation(coordinate: coords, title: "", subtitle: "")
                    self.mapper?.addAnnotation(annotation)
                    self.mapper?.setCenterOfMapToLocation(CLLocationCoordinate2DMake(coords.latitude, coords.longitude))
                }
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.activityIndicator.stopAnimating()
            })
        }
    }

    // Cancel and do not post any information
    @IBAction func cancelButtonTouch(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Hide the location prompts and display the map and link prompt
    func showMapAndUrlViews() {
        locationPromptLabel.hidden = true
        locationTextFieldView.hidden = true
        findOnTheMapButton.hidden = true
        mapView.hidden = false
        submitInformationButton.hidden = false
        urlTextFieldView.hidden = false
    }
}

// MARK: Implementation of UITextFieldDelegate method
extension InformationPostingViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

