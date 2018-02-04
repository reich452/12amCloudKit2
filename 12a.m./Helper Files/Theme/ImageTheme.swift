//
//  ImageTheme.swift
//  12a.m.
//
//  Created by Nick Reichard on 2/2/18.
//  Copyright © 2018 Nick Reichard. All rights reserved.
//

import UIKit
@IBDesignable

class ProfileImage: UIImageView {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var boarderWith: CGFloat = 0 {
        didSet {
            layer.borderWidth = boarderWith
        }
    }
}
