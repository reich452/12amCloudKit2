//
//  ProfileDetailViewController.swift
//  12a.m.
//
//  Created by Nick Reichard on 4/7/18.
//  Copyright © 2018 Nick Reichard. All rights reserved.
//

import UIKit

class ProfileDetailViewController: UIViewController {
    
    @IBOutlet weak var profileCollectionView: UICollectionView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var followCountLabel: UILabel!
    @IBOutlet weak var shotsCountLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        profileCollectionView.delegate = self
        profileCollectionView.dataSource = self
  
        setUpView()
        setUpAppearance()
       
    }
    
    // MARK: - Properties
    
    var comment: Comment?
    var post: Post?
    var user: User?
    
    // MARK: - Actions
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func followButtonTapped(_ sender: UIButton) {
    }
    
    // MARK: - View
    
    func setUpView() {
        guard let postOwner = post?.owner else { return }

        let ownerProfileImage = postOwner.photo
            
        profileImageView.image =  ownerProfileImage
        usernameLabel.text = postOwner.username
       
        likeCountLabel.text = "\(postOwner.likedPostRefs.count)"
        if postOwner.posts?.count == 0 {
            shotsCountLabel.text = "No Posts Yet!"
        } else {
            shotsCountLabel.text = "\(postOwner.posts?.count ?? 0)"
        }
    }
    
    
    private func setUpAppearance() {
        self.profileImageView.layer.cornerRadius = self.profileImageView.layer.frame.height / 2
        self.profileImageView.clipsToBounds = true
        self.profileImageView.contentMode = .scaleAspectFill
        self.profileImageView.layer.borderWidth = 1.8
        self.profileImageView.layer.borderColor = UIColor.white.cgColor
    }
 

}


extension ProfileDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let postOwner = post?.owner else { return 0 }
        let postCount = postOwner.posts?.count
        return postCount ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.postOwnerCell, for: indexPath) as? ProfileDetailCollectionViewCell else { return UICollectionViewCell() }
        
        guard let postOwner = self.post?.owner else { return UICollectionViewCell() }
        let post = postOwner.posts?[indexPath.row]
        cell.userPostImageView.image = post?.photo
        
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
