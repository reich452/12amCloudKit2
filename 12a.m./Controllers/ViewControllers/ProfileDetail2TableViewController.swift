//
//  ProfileDetail2TableViewController.swift
//  12a.m.
//
//  Created by Nick Reichard on 12/12/17.
//  Copyright © 2017 Nick Reichard. All rights reserved.
//

import UIKit
import CoreLocation

class ProfileDetail2TableViewController: UITableViewController {
    
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
        self.setUpViewFromFeed()
        self.setUpAppearance()
       
       
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.locationManager2.stopUpdatingLocation()
    }
    
    // MARK: - Properties
    
    var comment: Comment?
    var post: Post?
    fileprivate let locationManager2 = CLLocationManager()
    
    // MARK: - Actions
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - View

   private func setUpViewFromFeed() {
        guard let owner = post?.owner else { return }
        self.profileImageView.image = owner.photo
        self.usernameLabel.text = owner.username
        self.cityLabel.text = owner.city
        self.countryLabel.text = owner.country
        self.stateLabel.text = owner.state
    }
    
    private func setUpAppearance() {
        self.profileImageView.layer.cornerRadius = self.profileImageView.layer.frame.height / 2
        self.profileImageView.clipsToBounds = true
        self.profileImageView.contentMode = .scaleAspectFill
        self.profileImageView.layer.borderWidth = 1.8
        self.profileImageView.layer.borderColor = UIColor.white.cgColor
    }
}


// MARK: - CollectionView

extension ProfileDetail2TableViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let ownerPosts = post?.owner?.posts?.count
        return ownerPosts ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell2", for: indexPath) as? ProfileDetail2CollectionViewCell else { return UICollectionViewCell() }
        
        let ownerPosts = post?.owner?.posts
        guard let sortedPosts = ownerPosts?.sorted(by: { $0.timestamp.compare($1.timestamp) == .orderedDescending }) else { return UICollectionViewCell() }
        let sortedIndexPath = sortedPosts[indexPath.row]
        cell.userPostImageView.image = sortedIndexPath.photo
        
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
