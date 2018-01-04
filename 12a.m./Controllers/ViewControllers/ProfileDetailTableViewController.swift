//
//  ProfileDetailTableViewController.swift
//  12a.m.
//
//  Created by Nick Reichard on 12/7/17.
//  Copyright © 2017 Nick Reichard. All rights reserved.
//

import UIKit
import CoreLocation

class ProfileDetailTableViewController: UITableViewController {
    
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
    }
    
    // MARK: - Properties
    
    var comment: Comment?
    var post: Post?
  
    // MARK: - Actions
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
 
    // MARK: - View
    
    func setUpView() {
        guard let owner = comment?.owner else { return }
        self.usernameLabel.text = owner.username
        self.profileImageView.image = owner.photo
        self.cityLabel.text = owner.city
        self.countryLabel.text = owner.country
        self.stateLabel.text = owner.state
    }
    
    func setUpViewFromFeed() {
        guard let owner = post?.owner else { return }
        self.profileImageView.image = owner.photo
        self.usernameLabel.text = owner.username
        self.cityLabel.text = owner.city
        self.stateLabel.text = owner.state
        self.countryLabel.text = owner.country
    }

    private func setUpAppearance() {
        self.profileImageView.layer.cornerRadius = self.profileImageView.layer.frame.height / 2.1
        self.profileImageView.clipsToBounds = true
        self.profileImageView.contentMode = .scaleAspectFill
        self.profileImageView.layer.borderWidth = 1.8
        self.profileImageView.layer.borderColor = UIColor.white.cgColor
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




