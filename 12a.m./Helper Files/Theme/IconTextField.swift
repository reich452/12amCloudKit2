//
//  IconTextField.swift
//  12a.m.
//
//  Created by Nick Reichard on 11/16/17.
//  Copyright © 2017 Nick Reichard. All rights reserved.
//

import UIKit
@IBDesignable
class IconTextField: UITextField {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var leftImage: UIImage? {
        didSet {
            updateTextField()
        }
    }
    
    @IBInspectable var leftPadding: CGFloat = 0 {
        didSet {
            updateTextField()
        }
    }
    @IBInspectable var imageWidth: CGFloat = 0 {
        didSet {
            updateTextField()
        }
    }
    
    @IBInspectable var imageHeight: CGFloat = 0 {
        didSet {
            updateTextField()
        }
    }
    
    func updateTextField() {
        attributedPlaceholder = NSAttributedString(string: placeholder != nil ? placeholder! : "", attributes: [NSAttributedStringKey.foregroundColor: tintColor])
        
        guard let image = leftImage else {
            leftViewMode = .never
            return
        }
        leftViewMode = .always
        
        let imageView = UIImageView(frame: CGRect(x: leftPadding, y: 0, width: imageWidth, height: imageHeight))
        imageView.image = image
        imageView.tintColor = tintColor
        
        var width = leftPadding + 20
        
        if borderStyle == UITextBorderStyle.none || borderStyle == UITextBorderStyle.line {
            width = width + 5
        }
        let view = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 20))
        view.addSubview(imageView)
        leftView = view
    }
}
