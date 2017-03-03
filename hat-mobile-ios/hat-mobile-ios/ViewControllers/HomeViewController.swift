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

/// The class responsible for the landing screen
class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Variables
    
    /// The tiles to show
    private var tiles: [HomeScreenObject] = []
    
    /// Device's orientation, used to format the collection view cell according to width of the screen
    private var orientation: UIInterfaceOrientation = .portrait
    
    // The authorise view to show if unauthorised
    private var authorise: AuthoriseUserViewController? = nil
    
    // MARK: - IBOutlets

    /// An IBOutlet for handling the collection view
    @IBOutlet weak var collectionView: UICollectionView!
    
    /// An IBOutlet for handling the hello label on the top of the screen
    @IBOutlet weak var helloLabel: UILabel!
    
    // MARK: - IBActions
    
    /**
     Shows a pop up with the available settings
     
     - parameter sender: The object that called this method
     */
    @IBAction func SettingsButtonAction(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Settings", message: nil, preferredStyle: .actionSheet)
        
        let logOutAction = UIAlertAction(title: "Log out", style: .default, handler: {(alert: UIAlertAction) -> Void
            
            in
            TabBarViewController.logoutUser(from: self)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(logOutAction)
        alertController.addAction(cancelAction)
        
        // if user is on ipad show as a pop up
        if UI_USER_INTERFACE_IDIOM() == .pad {
            
            alertController.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
            alertController.popoverPresentationController?.sourceView = self.view
        }
        
        // present alert controller
        self.navigationController!.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Collection View methods
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "homeScreenCell", for: indexPath) as? HomeCollectionViewCell
        
        return HomeCollectionViewCell.setUp(cell: cell!, indexPath: indexPath, object: tiles[indexPath.row], orientation: orientation)
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return tiles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // in case of landscape show 3 tiles instead of 2
        if self.orientation == .landscapeLeft || self.orientation == .landscapeRight {
            
            return CGSize(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.width / 3)
        }
        
        return CGSize(width: UIScreen.main.bounds.width / 2, height: UIScreen.main.bounds.width / 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: "homeHeader",
                                                                         for: indexPath) as! HomeHeaderCollectionReusableView
        headerView.headerTitle.text = "Data Services"
        
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if tiles[indexPath.row].serviceName == "Notes" {
            
            self.performSegue(withIdentifier: "notesSegue", sender: self)
        } else if tiles[indexPath.row].serviceName == "Locations" {
            
            self.performSegue(withIdentifier: "locationsSegue", sender: self)
        } else if tiles[indexPath.row].serviceName == "Social Data" {
            
            self.performSegue(withIdentifier: "socialDataSegue", sender: self)
        }
    }
    
    // MARK: - View controller methods

    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let notables = HomeScreenObject(name: "Notes", description: "Take notes, write lists or create life logs", image: UIImage(named: "notes")!)
        let locations = HomeScreenObject(name: "Locations", description: "Track your movements over the day or week", image: UIImage(named: "gps outlined")!)
        let socialData = HomeScreenObject(name: "Social Data", description: "Social media posts stored in your HAT", image: UIImage(named: "SocialFeed")!)
        let chat = HomeScreenObject(name: "Chat", description: "Coming Soon", image: UIImage(named: "Chat")!)
        self.tiles = [notables, locations, socialData, chat]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        // check orientation
        self.orientation = UIInterfaceOrientation(rawValue: UIDevice.current.orientation.rawValue)!
        
        func success(token: String) {
            
        }
        
        func failed() {
            
            if self.authorise == nil {
                
                self.authorise = AuthoriseUserViewController()
                self.authorise!.view.backgroundColor = .clear
                self.authorise!.view.frame = CGRect(x: self.view.center.x - 50, y: self.view.center.y - 20, width: 100, height: 40)
                self.authorise!.view.layer.cornerRadius = 15
                self.authorise!.completionFunc = nil
                
                // add the page view controller to self
                self.addChildViewController(self.authorise!)
                self.view.addSubview(self.authorise!.view)
                self.authorise!.didMove(toParentViewController: self)
            }
        }
        
        // get notes
        // reset the stack to avoid allowing back
        let result = KeychainHelper.GetKeychainValue(key: "logedIn")
        let userDomain = HatAccountService.TheUserHATDomain()
        /* we already have a hat_domain, ie. can skip the login screen? */
        if result != "true" && userDomain == "" {
            
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            self.navigationController?.title = ""
            let navigation = self.navigationController
            _ = navigation?.popToRootViewController(animated: false)
            navigation?.pushViewController(loginViewController, animated: false)
        } else {
            
            /* we already have a hat_domain, ie. can skip the login screen? */

            let array = userDomain.components(separatedBy: ".")
            self.helloLabel.text = "Hello " + array[0] + "!"
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.locationManager.requestAlwaysAuthorization()
            
            let token = HatAccountService.getUsersTokenFromKeychain()
            HatAccountService.checkIfTokenIsActive(token: token, success: success, failed: failed)
        }
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        
        // save orientation
        self.orientation = toInterfaceOrientation
        
        // reload collection view
        self.collectionView?.reloadData()
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
