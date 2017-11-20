//
//  ProfileViewController.swift
//  12a.m.
//
//  Created by Nick Reichard on 11/20/17.
//  Copyright © 2017 Nick Reichard. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - IBOutlets 
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var discriptionLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var currentCountryLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var currentStateLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var currentCityLabel: UILabel!
    @IBOutlet weak var usernameTextField: IconTextField!
    @IBOutlet weak var emailTextField: IconTextField!
    @IBOutlet weak var updateProfileButton: UIButton!
    
    // MARK: - Properties
    private var currentUser: User? {
        return UserController.shared.currentUser
    }
    private var imagePickerWasDismissed = false
    private let imagePicker = UIImagePickerController()
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        setUpAppearance()
        updateDiscription()
    }
    
    // MARK: - Delegates
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - Actions
    
    @IBAction func updateImageButtonTapped(_ sender: Any) {
        addedProfileImage()
    }
    
    @IBAction func updateButtonTapped(_ sender: Any) {
        
    }
    
    // MARK: - Update
   private func updateViews() {
        guard let user = self.currentUser,
            let userPhoto = self.currentUser?.photo else { return }
        self.usernameLabel.text = user.username
        self.profileImageView.image = userPhoto
        self.usernameTextField.text = "  \(user.username)"
        self.emailTextField.text = "  \(user.email)"
    }
   private func setUpAppearance() {
        self.profileImageView.layer.cornerRadius = self.profileImageView.layer.frame.height / 2
        self.profileImageView.contentMode = .scaleAspectFill
        self.profileImageView.layer.borderColor = UIColor.white.cgColor
        self.profileImageView.layer.borderWidth = 0.7
        self.profileImageView.clipsToBounds = true
        self.usernameTextField.textColor = UIColor.white
        self.emailTextField.textColor = UIColor.white
    
    }
    
   private func updateDiscription() {
        let posts = PostController.shared.posts
        let filterCount = posts.map {$0.ownerReference}
        if filterCount.count != 0 {
            discriptionLabel.text = "Posted \(filterCount.count) times at 12am - 1am"
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
