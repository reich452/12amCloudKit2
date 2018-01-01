//
//  ModalPreviewViewController.swift
//  12a.m.
//
//  Created by Nick Reichard on 12/28/17.
//  Copyright © 2017 Nick Reichard. All rights reserved.
//

import UIKit

class ModalPreviewViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var captionTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    fileprivate var location = CGPoint(x: 0, y: 0)
    fileprivate var capturedImage: UIImage?
    fileprivate let appDelegate = UIApplication.shared.delegate! as! AppDelegate
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = capturedImage
        
        imageCaptionTextFieldGestures()
        
        captionTextField.delegate = self
        
        // Tap anywhere on the screen to dismiss the keyboard
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        
    }
    
    // MARK: - TextField Functions
    
    func imageCaptionTextFieldGestures() {
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(CameraPreviewViewController.draggedView(_:)))
        
        captionTextField.addGestureRecognizer(panGesture)
        captionTextField.isUserInteractionEnabled = true
        
    }
    
    // Press return to dismiss keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        captionTextField.resignFirstResponder()
        return true
    }
    
    // The following four functions allow the textField to be dragged around
    
    // Haven't tested but the userDragged function may not be needed since draggedView function does the same and sets bounds
    func userDragged(gesture: UIPanGestureRecognizer){
        let loc = gesture.location(in: self.view)
        self.captionTextField.center = loc
    }
    
    func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        let touch : UITouch! = touches.first as? UITouch
        
        location = touch.location(in: self.view)
        
        captionTextField.center = location
    }
    
    func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        let touch : UITouch! = touches.first as? UITouch
        
        location = touch.location(in: self.view)
        
        captionTextField.center = location
    }
    
    func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch : UITouch! = touches.first
        
        let location = touch.location(in: self.view)
        
        captionTextField.center = location
    }
    
    // Function that sets bounds of dragging textField around screen
    @objc func draggedView(_ sender: UIPanGestureRecognizer) {
        
        guard let senderView = sender.view else {
            return
        }
        
        var translation = sender.translation(in: view)
        
        translation.x = max(translation.x, imageView.frame.minX - captionTextField.frame.minX)
        translation.x = min(translation.x, imageView.frame.maxX - captionTextField.frame.maxX)
        
        translation.y = max(translation.y, imageView.frame.minY - captionTextField.frame.minY)
        translation.y = min(translation.y, imageView.frame.maxY - captionTextField.frame.maxY)
        
        senderView.center = CGPoint(x: senderView.center.x + translation.x, y: senderView.center.y + translation.y)
        sender.setTranslation(.zero, in: view)
        view.bringSubview(toFront: senderView)
    }
    
    
    // MARK: - Image Gesture Functions
    
    // Function to add tap gesture to UIImageView
    //    func imageTapGesture() {
    //
    //        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
    //
    //        imageView.addGestureRecognizer(tap)
    //
    //        imageView.isUserInteractionEnabled = true
    //
    //        self.view.addSubview(view)
    //
    //    }
    
    // Function which brings up textField when UIImageView is tapped, called in imageTapGesture
    
    // MARK: - Image Gesture Functions
    
    // Function to add tap gesture to UIImageView
    //    func imageTapGesture() {
    //
    //        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
    //
    //        imageView.addGestureRecognizer(tap)
    //
    //        imageView.isUserInteractionEnabled = true
    //
    //        self.view.addSubview(view)
    //
    //    }
    
    //     Function which brings up textField when UIImageView is tapped, called in imageTapGesture
    func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        _ = tapGestureRecognizer.view as! UIImageView
        
        // Your action
    }
    
    
    // MARK: - Action
    
    @IBAction func usePhotoButtonTapped(_ sender: UIButton) {
        guard let commentText = captionTextField.text,
            let image = imageView.image else { return }
        
        PostController.shared.createPost(image: image, text: commentText) { (post) in
            
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let feedTVC = storyboard.instantiateViewController(withIdentifier: "feedTVC") as? FeedTableViewController {
            self.present(feedTVC, animated: true, completion: nil)
        }
        
        let initialViewController = self.storyboard!.instantiateViewController(withIdentifier: "customTabBar")
        appDelegate.window?.rootViewController = initialViewController
        appDelegate.window?.makeKeyAndVisible()
    }
    
    
    @IBAction func imageToTextFieldButton(_ sender: Any) {
        
        
    }
    
    fileprivate func usePhoto() {
        guard let commentText = captionTextField.text, let image = imageView.image else { return }
        
        PostController.shared.createPost(image: image, text: commentText) { (post) in
            
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let feedTVC = storyboard.instantiateViewController(withIdentifier: "feedTVC") as? FeedTableViewController {
            self.present(feedTVC, animated: true, completion: nil)
        }
        
        let initialViewController = self.storyboard!.instantiateViewController(withIdentifier: "customTabBar")
        appDelegate.window?.rootViewController = initialViewController
        appDelegate.window?.makeKeyAndVisible()
    }
}


