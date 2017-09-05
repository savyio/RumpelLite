/**
 * Copyright (C) 2017 HAT Data Exchange Ltd
 *
 * SPDX-License-Identifier: MPL2
 *
 * This file is part of the Hub of All Things project (HAT).
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/
 */

import UIKit

// MARK: Class

/// A pop up view controller in ProfileViewController about PHATA
internal class LearnMorePHATAViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    /// An IBOutlet for controlling the label that has the info
    @IBOutlet private weak var details: UILabel!
    
    // MARK: - IBActions
    
    /**
     Posts a notification to hide this pop up view controller since the user wants to hide it.
     
     - parameter sender: The object that calls this method
     */
    @IBAction func cancelButtonAction(_ sender: Any) {
        
        NotificationCenter.default.post(name: NSNotification.Name(Constants.NotificationNames.hideLearnMore), object: nil)
    }
    
    // MARK: - View Controller methods

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // set the desired text
        self.details.text = "Your Savy address is your username (e.g. yourname.savy.io). It is similar to a PO Box or a nickname for your Savy. \n\n It is what you use to sign in on to Savy-ready services on the internet. You can set up your Savy page and it can then be your personal home page on the Internet. Customise what information you wish to share on your Savy page here. "
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
}
