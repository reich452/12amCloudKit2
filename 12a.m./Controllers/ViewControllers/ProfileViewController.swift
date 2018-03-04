//
//  ProfileViewController.swift
//  12a.m.
//
//  Created by Nick Reichard on 11/20/17.
//  Copyright © 2017 Nick Reichard. All rights reserved.
//

import UIKit
import CoreLocation

class ProfileViewController: ShiftableViewController {
    
    // MARK: - IBOutlets 
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var discriptionLabel: UILabel!
    @IBOutlet weak var usernameTextField: IconTextField!
    @IBOutlet weak var emailTextField: IconTextField!
    @IBOutlet weak var updateProfileButton: UIButton!
    @IBOutlet weak var profileImageButton: UIButton!
    
    // MARK: - Properties
    private var currentUser: User? {
        return UserController.shared.currentUser
    }
    private var imagePickerWasDismissed = false
    private let imagePicker = UIImagePickerController()
    private let locationManager = CLLocationManager()
    private let locator = Locator.self
    private let placemark: CLPlacemark? = nil
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.usernameTextField.delegate = self
        self.emailTextField.delegate = self
        
        setUpAppearance()
        updateViews()
        updateDiscription()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateViews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.locationManager.stopUpdatingLocation()
    }
    
    // MARK: - Actions
    
    @IBAction func updateImageButtonTapped(_ sender: Any) {
        self.addedProfileImage()
    }
    
    @IBAction func updateButtonTapped(_ sender: Any) {
        self.updateUserInfo()
    }
    
    @IBAction func infoButtonTapped(_ sender: UIButton) {
        
    }
    
    // MARK: - Update & Appearance
    @objc private func updateViews() {
        guard let user = self.currentUser else { return }
    
        self.usernameLabel.text = user.username
        self.usernameTextField.text = " \(user.username)"
        self.emailTextField.text = " \(user.email)"
        
    }
    private func setUpAppearance() {
        profileImageView.layer.cornerRadius = self.profileImageView.layer.frame.width / 2
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.layer.borderWidth = 0.7
        profileImageView.clipsToBounds = true
        usernameTextField.textColor = UIColor.white
        emailTextField.textColor = UIColor.white
        updateProfileButton.layer.borderColor = UIColor.white.cgColor
        updateProfileButton.layer.cornerRadius = 15
        updateProfileButton.backgroundColor = .white
        updateProfileButton.titleLabel?.textColor = .clear
        updateProfileButton.clipsToBounds = true
        
        if self.currentUser == nil {
            self.profileImageView.image = #imageLiteral(resourceName: "UnisexAvatar")
        } else {
            self.profileImageView.image = currentUser?.photo
        }
        
    }
    
    private func updateUserInfo() {
        guard let userName = self.usernameTextField.text, userName != "", let email = self.emailTextField.text, email != "", let profileImage = self.profileImageView.image else { return }
        
        if UserController.shared.currentUser != nil {
            UserController.shared.updateCurrentUser(username: userName, email: email, profileImage: profileImage, completion: { (success) in
                if !success {
                    print("Error updating current user")
                } else {
                    print("Updated current user personal info")
                }
                DispatchQueue.main.async {
                    self.usernameLabel.text = userName
                    self.emailTextField.text = email
                    self.profileImageView.image = profileImage
                }
            })
        }
    }
    
    private func updateDiscription() {
        // does it look better with or without this ??
//        discriptionLabel.isHidden = true
        let posts = PostController.shared.posts.map {$0.ownerReference}
        if posts.count != 0 {
            discriptionLabel.text = "Posted \(posts.count) times at 12am - 1am"
        } else {
            discriptionLabel.text = "You hanv't posted at 12am yet"
        }
    }
    
}


extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func addedProfileImage() {
        if UIImagePickerController.isSourceTypeAvailable(.camera)  {
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .camera
            imagePicker.cameraCaptureMode = .photo
            imagePicker.modalPresentationStyle = .popover
            imagePicker.delegate = self
            self.present(imagePicker, animated:  true, completion: nil)
            
        } else {
            noCameraOnDevice()
        }
    }
    
    func noCameraOnDevice() {
        let alertVC = UIAlertController(title: "No Camera", message: "Sorry, this device has no camera", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertVC.addAction(okAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        if chosenImage != nil {
            profileImageView.contentMode = .scaleAspectFill
            profileImageView.image = chosenImage
            
        }
        self.imagePickerWasDismissed = true
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.imagePickerWasDismissed = true
        dismiss(animated: true, completion: nil)
    }
}
