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
        mapView.hidden = true
        submitInformationButton.hidden = true
        urlTextFieldView.hidden = true
        urlTextField.delegate = self
        
        // Round the corners of the button
        findOnTheMapButton.layer.cornerRadius = 8
        submitInformationButton.layer.cornerRadius = 8
        
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

            locationTextField.becomeFirstResponder()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submitInformationButtonTouch(sender: UIButton) {
        OTMClient.sharedInstance().validateURL(urlTextField.text) { result, error in
            if let error = error {
                println("Error validating URL: \(error.localizedDescription)")
            } else {
                println("Valid url")
            }
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func findOnTheMapButtonTouch(sender: UIButton) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(locationTextField.text) { placemarks, error in
            if let error = error {
                println("Geocode failed with error: \(error.localizedDescription)")
            } else {
                if let placemarks = placemarks {
                    self.showMapAndUrlViews()
                    self.mapper = OTMMapper(mapView: self.mapView)
                    let placemark = placemarks[0] as! CLPlacemark
                    let location = placemark.location
                    let coords = location.coordinate
                    self.locationCoordinates = location.coordinate
                    let annotation = OTMAnnotation(coordinate: coords, title: "", subtitle: "")
                    self.mapper?.addAnnotation(annotation)
                    self.mapper?.setCenterOfMapToLocation(CLLocationCoordinate2DMake(coords.latitude, coords.longitude), latitudinalMeters: 1000.0, longitudinalMeters: 1000.0)
                }
            }
        }
    }

    func showMapAndUrlViews() {
        locationPromptLabel.hidden = true
        locationTextFieldView.hidden = true
        findOnTheMapButton.hidden = true
        mapView.hidden = false
        submitInformationButton.hidden = false
        urlTextFieldView.hidden = false
    }
}

extension InformationPostingViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

