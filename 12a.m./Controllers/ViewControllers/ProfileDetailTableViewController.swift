//
//  ProfileDetailTableViewController.swift
//  12a.m.
//
//  Created by Nick Reichard on 12/7/17.
//  Copyright © 2017 Nick Reichard. All rights reserved.
//

import UIKit
import CoreLocation

class ProfileDetailTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.setUpView()
        self.setUpViewFromFeed()
        self.setUpAppearance()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.locationManager.stopUpdatingLocation()
    }
    
    // MARK: - Properties
    
    var comment: Comment?
    var post: Post?
    private let locationManager = CLLocationManager()
    
    // MARK: - Actions
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
 
    // MARK: - View
    
    func setUpView() {
        guard let owner = comment?.owner else { return }
        self.usernameLabel.text = owner.username
        self.profileImageView.image = owner.photo
    }
    
    func setUpViewFromFeed() {
        guard let owner = post?.owner else { return }
        self.profileImageView.image = owner.photo
        self.usernameLabel.text = owner.username
    }

    private func setUpAppearance() {
        self.profileImageView.layer.cornerRadius = self.profileImageView.layer.frame.height / 2
        self.profileImageView.clipsToBounds = true
        self.profileImageView.contentMode = .scaleAspectFill
        self.profileImageView.layer.borderWidth = 1.8
        self.profileImageView.layer.borderColor = UIColor.white.cgColor
    }
}

// MARK: - CLLocationManagerDelegate 

extension ProfileDetailTableViewController {
    
    // MARK: - Location
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = manager.location else { return }
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            if (error != nil) {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }
            if (placemarks?.count)! > 0 {
                
                print("placemarks",placemarks ?? 0)
                let pm = placemarks?[0]
                self.displayLocationInfo(pm)
            } else {
                print("Problem with the data received from geocoder")
            }
        })
    }
    
    func displayLocationInfo(_ placemark: CLPlacemark?) {
        if let containsPlacemark = placemark {
            
            print("your location is:-",containsPlacemark)
            //stop updating location to save battery life
            locationManager.stopUpdatingLocation()
            let locality = (containsPlacemark.locality != nil) ? containsPlacemark.locality : ""
            let country = (containsPlacemark.country != nil) ? containsPlacemark.country : ""
            let state = (containsPlacemark.administrativeArea != nil) ? containsPlacemark.administrativeArea : ""
            
            
            let unitedStates = "United States"
            if (country?.contains(unitedStates))! {
                self.countryLabel.text = "U.S.A"
            } else {
                self.countryLabel.text = country
            }
            self.cityLabel.text = locality
            self.stateLabel.text = state 
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while updating location " + error.localizedDescription)
    }
}

// MARK: - CollectionView

extension ProfileDetailTableViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let ownerPosts = comment?.owner?.posts?.count
        return ownerPosts ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as? ProfileDetailCollectionViewCell else { return UICollectionViewCell() }
        
        let ownerPosts = comment?.owner?.posts
        guard let sortedPosts = ownerPosts?.sorted(by: { $0.timestamp.compare($1.timestamp) == .orderedDescending }) else { return UICollectionViewCell() }
        let sortedIndexPath = sortedPosts[indexPath.row]
        cell.userPostedImageView.image = sortedIndexPath.photo
       
        return cell 
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // number of Col.
        let nbCol = 3
        
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(nbCol - 1))
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(nbCol))
        return CGSize(width: size, height: size)
    }
}




