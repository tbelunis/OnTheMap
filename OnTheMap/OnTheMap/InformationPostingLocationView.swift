//
//  InformationPostingLocationView.swift
//  OnTheMap
//
//  Created by TOM BELUNIS on 5/21/15.
//  Copyright (c) 2015 TOM BELUNIS. All rights reserved.
//

import UIKit

class InformationPostingLocationView: UIView {

    @IBOutlet weak var locationPromptLabel: UILabel!
    @IBOutlet weak var locationEntryTextField: UITextField!
    @IBOutlet weak var findOnTheMapButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        
        locationPromptLabel = UILabel()
        // Round the corners of the button
        findOnTheMapButton.layer.cornerRadius = 8
        
        var line2: NSAttributedString = NSAttributedString(string: "")
        let fgColor: UIColor = UIColor.redColor()
        
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
            
            locationEntryTextField.becomeFirstResponder()
        }
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
