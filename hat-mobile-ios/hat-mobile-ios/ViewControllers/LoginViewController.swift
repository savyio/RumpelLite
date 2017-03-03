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

import SafariServices
import MessageUI

// MARK: Class

/// The Login View Controller
class LoginViewController: UIViewController, UITextFieldDelegate, MFMailComposeViewControllerDelegate, UIPopoverPresentationControllerDelegate {
    
    // MARK: - IBOutlets

    /// An IBOutlet for handling the learnMoreButton
    @IBOutlet weak var learnMoreButton: UIButton!
    /// An IBOutlet for handling the getAHATButton
    @IBOutlet weak var getAHATButton: UIButton!
    /// An IBOutlet for handling the buttonLogon
    @IBOutlet weak var buttonLogon: UIButton!
    /// An IBOutlet for handling the joinCommunityButton
    @IBOutlet weak var joinCommunityButton: UIButton!
    /// An IBOutlet for handling the domainButton
    @IBOutlet weak var domainButton: UIButton!
    
    /// An IBOutlet for handling the inputUserHATDomain
    @IBOutlet weak var inputUserHATDomain: UITextField!
    
    /// An IBOutlet for handling the labelAppVersion
    @IBOutlet weak var labelAppVersion: UILabel!
    
    /// An IBOutlet for handling the labelTitle
    @IBOutlet weak var labelTitle: UITextView!
    /// An IBOutlet for handling the labelSubTitle
    @IBOutlet weak var labelSubTitle: UITextView!
    
    @IBOutlet weak var testImage: UIImageView!
    /// An IBOutlet for handling the ivLogo
    @IBOutlet weak var ivLogo: UIImageView!
    
    /// An IBOutlet for handling the scrollView
    @IBOutlet weak var scrollView: UIScrollView!
    
    // MARK: - Variables
    
    /// A String typealias
    typealias MarketAccessToken = String
   
    /// SafariViewController variable
    private var safariVC: SFSafariViewController?
        
    // MARK: - IBActions
    
    @IBAction func domainButtonAction(_ sender: Any) {
        
        let alert = UIAlertController(title: "Select domain", message: nil, preferredStyle: .actionSheet)
        
        let hubofallthingsAction = UIAlertAction(title: ".hubofallthings.net", style: .default, handler: {(alert: UIAlertAction) -> Void in
            
            self.domainButton.setTitle(".hubofallthings.net", for: .normal)
        })
        
        let bsafeAction = UIAlertAction(title: ".bsafe.org", style: .default, handler: {(alert: UIAlertAction) -> Void in
            
            self.domainButton.setTitle(".bsafe.org", for: .normal)
        })
        
        let hubatAction = UIAlertAction(title: ".hubat.net", style: .default, handler: {(alert: UIAlertAction) -> Void in
            
            self.domainButton.setTitle(".hubat.net", for: .normal)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(hubofallthingsAction)
        alert.addAction(bsafeAction)
        alert.addAction(hubatAction)
        alert.addAction(cancelAction)
        
        // if user is on ipad show as a pop up
        if UI_USER_INTERFACE_IDIOM() == .pad {
            
            alert.popoverPresentationController?.sourceRect = self.domainButton.frame
            alert.popoverPresentationController?.sourceView = self.domainButton
        }
        
        // present alert controller
        self.navigationController!.present(alert, animated: true, completion: nil)
    }
    
    /**
     A button launching email view controller
     
     - parameter sender: The object that called this method
     */
    @IBAction func contactUsActionButton(_ sender: Any) {
        
        if MFMailComposeViewController.canSendMail() {
            
            // create mail view controler
            let mailVC = MFMailComposeViewController()
            mailVC.mailComposeDelegate = self
            mailVC.setToRecipients(["contact@hatdex.org"])
            
            // present view controller
            self.present(mailVC, animated: true, completion: nil)
        } else {
            
            self.createClassicOKAlertWith(alertMessage: "This device has not been configured to send emails", alertTitle: "Email services disabled", okTitle: "ok", proceedCompletion: {})
        }
    }
    
    /**
     A button opening safari to redirect user to mad hatters
     
     - parameter sender: The object that called this method
     */
    @IBAction func joinOurCommunityButtonAction(_ sender: Any) {
        
        let urlStr = "http://hubofallthings.com/main/the-mad-hatters/"
        if let url = URL(string: urlStr) {
            
            UIApplication.shared.openURL(url)
        }
    }
    /**
     An action executed when the logon button is pressed
     
     - parameter sender: The object that calls this method
     */
    @IBAction func buttonLogonTouchUp(_ sender: AnyObject) {
        
        let failed = {
            
            self.createClassicOKAlertWith(alertMessage: "Please check your personal hat address again", alertTitle: "Wrong domain!", okTitle: "OK", proceedCompletion: {() -> Void in return})
        }
        
        let filteredDomain = self.removeDomainFromUserEnteredText(domain: inputUserHATDomain.text!)
        HatAccountService.logOnToHAT(userHATDomain: filteredDomain + (self.domainButton.titleLabel?.text)!, successfulVerification: self.authoriseUser, failedVerification: failed)
    }
    
    // MARK: - Remove domain from entered text
    
    /**
     Removes domain from entered text
     
     - parameter domain: The user entered text
     - returns: The filtered text
     */
    private func removeDomainFromUserEnteredText(domain: String) -> String {
        
        let array = domain.components(separatedBy: ".")
        
        if array.count > 0 {
            
            return array[0]
        }
        
        return domain
    }
    // MARK: - View Controller functions
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // add keyboard handling
        self.addKeyboardHandling()
        self.hideKeyboardWhenTappedAround()
        
        // disable the navigation back button
        self.navigationItem.setHidesBackButton(true, animated:false)
        
        // set title
        self.title = NSLocalizedString("logon_label", comment:  "logon title")
        
        // format title label
        let textAttributesTitle = [
            NSForegroundColorAttributeName: UIColor.white,
            NSStrokeColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "OpenSans-CondensedLight", size: 36)!,
            NSStrokeWidthAttributeName: -1.0
            ] as [String : Any]
        
        let textAttributes = [
            NSForegroundColorAttributeName: UIColor.tealColor(),
            NSStrokeColorAttributeName: UIColor.tealColor(),
            NSFontAttributeName: UIFont(name: "OpenSans-CondensedLight", size: 36)!,
            NSStrokeWidthAttributeName: -1.0
            ] as [String : Any]
        
        let partOne = NSAttributedString(string: "Rumpel ", attributes: textAttributesTitle)
        let partTwo = NSAttributedString(string: "Lite", attributes: textAttributes)
        let combination = NSMutableAttributedString()
        
        combination.append(partOne)
        combination.append(partTwo)
        self.labelTitle.attributedText = combination
        self.labelTitle.textAlignment = .center
        
        // move placeholder inside by 5 points
        self.inputUserHATDomain.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0)
        
        // input
        inputUserHATDomain.placeholder = NSLocalizedString("hat_domain_placeholder", comment:  "user HAT domain")

        // button
        buttonLogon.setTitle(NSLocalizedString("logon_label", comment:  "username"), for: UIControlState())
        buttonLogon.backgroundColor = Constants.Colours.AppBase
        
        // Create a button bar for the number pad
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 35)
        
        if let result = KeychainHelper.GetKeychainValue(key: Constants.Keychain.HATDomainKey) {
            
            let barButtonTitle = result
            
            // Setup the buttons to be put in the system.
            let autofillButton = UIBarButtonItem(title: barButtonTitle, style: .done, target: self, action: #selector(self.autofillPHATA))
            autofillButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "OpenSans", size: 16.0)!, NSForegroundColorAttributeName: UIColor.white], for: .normal)
            toolbar.barTintColor = .black
            toolbar.setItems([autofillButton], animated: true)
            
            if barButtonTitle != "" {
                
                self.inputUserHATDomain.inputAccessoryView = toolbar
                self.inputUserHATDomain.inputAccessoryView?.backgroundColor = .black
            }
        }
        
        // app version
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            
            self.labelAppVersion.text = "v." + version
        }
        
        // add notification observer for the login in
        NotificationCenter.default.addObserver(self, selector: #selector(self.hatLoginAuth), name: NSNotification.Name(rawValue: Constants.Auth.NotificationHandlerName), object: nil)
        
        self.joinCommunityButton.addBorderToButton(width: 1, color: .white)
        self.getAHATButton.addBorderToButton(width: 1, color: .white)
        self.learnMoreButton.addBorderToButton(width: 1, color: .white)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        // when the view appears clear the text field. The user might pressed sing out, this field must not contain the previous address
        self.inputUserHATDomain.text = ""
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        
        return .none
    }
    
    // MARK: - Mail View controller
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        // Check the result or perform other tasks.
        
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Accesory Input View Method
    
    /**
     Fills the domain text field with the user's domain
     */
    @objc private func autofillPHATA() {
        
        if let result = KeychainHelper.GetKeychainValue(key: Constants.Keychain.HATDomainKey) {
            
            let domain = result.components(separatedBy: ".")
            self.inputUserHATDomain.text = domain[0]
            self.domainButton.setTitle("." + domain[1] + "." + domain[2], for: .normal)
        }
    }
    
    // MARK: - Authorisation functions
    
    /**
     Authorise user with the hat
     
     - parameter hatDomain: The phata address of the user
     */
    private func authoriseUser(hatDomain: String) {
        
        // build up the hat domain auth url
        let hatDomainURL = "https://" + hatDomain + "/hatlogin?name=" + Constants.Auth.ServiceName + "&redirect=" +
            Constants.Auth.URLScheme + "://" + Constants.Auth.LocalAuthHost
        
        let authURL = NSURL(string: hatDomainURL)
        
        // open the log in procedure in safari
        safariVC = SFSafariViewController(url: authURL as! URL)
        if let vc: SFSafariViewController = self.safariVC {
            
            self.present(vc, animated: true, completion: nil)
        }        
    }
    
    /**
     The notification received from the login precedure.
     
     - parameter NSNotification: notification
     */
    @objc private func hatLoginAuth(notification: NSNotification) {
        
        // get the url form the auth callback
        let url = notification.object as! NSURL
        
        // first of all, we close the safari vc
        if let vc: SFSafariViewController = safariVC {
            
            vc.dismiss(animated: true, completion: nil)
        }
        
        // authorize with hat
        let filteredDomain = self.removeDomainFromUserEnteredText(domain: inputUserHATDomain.text!)
        HatAccountService.loginToHATAuthorization(userDomain: filteredDomain + (self.domainButton.titleLabel?.text)!, url: url, selfViewController: self, completion: nil)
    }
    
    /**
     Saves the hatdomain from token to keychain for easy log in
     
     - parameter userDomain: The user's domain
     - parameter HATDomainFromToken: The HAT domain extracted from the token
     */
    func authoriseAppToWriteToCloud(_ userDomain: String,_ HATDomainFromToken: String) {
        
        HatAccountService.authoriseAppToWriteToCloud(userDomain, HATDomainFromToken, viewController: self)
    }
    
    // MARK: - Keyboard handling
    
    override func keyboardWillHide(sender: NSNotification) {
        
        self.hideKeyboardInScrollView(scrollView)
    }
    
    override func keyboardWillShow(sender: NSNotification) {
        
        self.showKeyboardInView(self.view, scrollView: self.scrollView, sender: sender)
    }
}
