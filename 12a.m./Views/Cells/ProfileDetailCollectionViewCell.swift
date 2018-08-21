//
//  ProfileDetailCollectionViewCell.swift
//  12a.m.
//
//  Created by Nick Reichard on 12/11/17.
//  Copyright © 2017 Nick Reichard. All rights reserved.
//

import UIKit


class ProfileDetailCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var userPostImageView: UIImageView!
    
    var postImage: UIImage? {
        didSet {
            updateViews()
        }
    }
    // MARK: - TODO cornerRadius
    func updateViews() {
        guard let userPostImageView = userPostImageView else { return }
        userPostImageView.clipsToBounds = true
        userPostImageView.layer.cornerRadius = 10
        userPostImageView.image = postImage
    }
    
}
