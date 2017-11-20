//
//  LogInViewController.swift
//  12a.m.
//
//  Created by Nick Reichard on 11/3/17.
//  Copyright © 2017 Nick Reichard. All rights reserved.
//

import UIKit

enum ButtonState {
    case selected
    case notSelected
}

class LogInViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var userNameUiView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailUIView: UIView!
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var headerUIView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var profileBackgroundImageView: UIImageView!
    
    
    // MARK: - Properties
    private var currentUser: User? {
        return UserController.shared.currentUser
    }
    private var buttonState: ButtonState = .notSelected
    private var imagePickerWasDismissed = false
    private let imagePicker = UIImagePickerController()
    private var isTaken: Bool = true
    
    
    // MARK: - Life Cycle 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userNameTextField.delegate = self
        self.emailTextField.delegate = self
        setAppearance()
        updateViews()
    }
    
    // MARK: - Actions
    
    @IBAction func logInButtonTapped(_ sender: UIButton) {
        logInButtonClicked()
        saveNewUser()
    }
    @IBAction func imagePickerButtonTapped(_ sender: UIButton) {
        addedProfileImage()
    }
    
    // MARK: - Delegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.userNameTextField.placeholder = ""
        self.emailTextField.placeholder = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func saveNewUser() {
        guard let userName = userNameTextField.text, userName != "", let email = emailTextField.text, email != "", let profileImage = profileImageView.image else { return }
        
        if UserController.shared.currentUser == nil {
            
            UserController.shared.createUser(with: userName, email: email, profileImage: profileImage, completion: { (success) in
                if !success {
                    if !success {
                        print("Not successfull creating new user")
                    } else {
                        print("Made a new user!")
                    }
                }
            })
        } else if isTaken {
            checkUsernameAvailablility()
        } else {
            UserController.shared.updateCurrentUser(username: userName, email: email, completion: { (success) in
                if !success {
                    print("Not successfull updating existing user")
                } else {
                    print("Made a new user!")
                }
            })
        }
    }
    
    
    func checkUsernameAvailablility() {
        guard let username = userNameTextField.text, username != "" else { return }
        
        UserController.shared.checkForExistingUserWith(username: username) { (isTaken) in
            if !isTaken {
                self.showAlertMessage(titleStr: "Username already choosen", messageStr: "Please Choose a different username")
            }
        }
    }
}

extension LogInViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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

extension LogInViewController {
    
    // MARK: - Main
    func logInButtonClicked() {
        switch buttonState {
        case .notSelected:
            buttonState = .selected
            
            loginButton.layer.cornerRadius = 8
            loginButton.layer.masksToBounds = true
            loginButton.layer.borderColor = UIColor.white.cgColor
            loginButton.layer.borderWidth = 2
            loginButton.setTitleColor(UIColor.white, for: .normal)
            loginButton.setTitle("Sign Up", for: .normal)
            
        case .selected:
            buttonState = .notSelected
            
            loginButton.layer.cornerRadius = 8
            loginButton.layer.masksToBounds = true
            loginButton.layer.backgroundColor = nil
            loginButton.layer.borderWidth = 2
            loginButton.setTitleColor(UIColor.primaryAppBlue, for: .normal)
            loginButton.setTitle("Login", for: .normal)
        }
    }
    
    // MARK: - UI
    func setAppearance() {
        self.view.backgroundColor = UIColor.backgroundAPpGrey
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
        
        //        headerImageView.image = UIImage(named: "whiteBackground")
        //        headerImageView.contentMode = .scaleAspectFill
        //        headerImageView.layer.masksToBounds = true
        //        headerUIView.backgroundColor = UIColor(white: 0.0, alpha: 0.3)
        
        self.profileBackgroundImageView.image = #imageLiteral(resourceName: "backgroundProfileImage")
        self.profileBackgroundImageView.contentMode = .scaleAspectFill
        self.profileBackgroundImageView.layer.cornerRadius = profileBackgroundImageView.layer.frame.height / 2
        self.profileBackgroundImageView.layer.masksToBounds = true
        self.profileImageView.image = UIImage(named: "avatar")
        self.profileImageView.contentMode = .scaleAspectFill
        self.profileImageView.layer.cornerRadius = profileImageView.layer.frame.height / 2
        self.profileImageView.layer.masksToBounds = true
        
        self.userNameTextField.backgroundColor = UIColor.clear
        self.emailTextField.backgroundColor = UIColor.clear
        
        self.tabBarController?.tabBarController?.tabBar.shadowImage = UIImage()
        self.tabBarController?.tabBarController?.tabBar.barStyle = .blackTranslucent
        self.tabBarController?.tabBarController?.tabBar.barTintColor = UIColor.clear
        self.tabBarController?.tabBarController?.tabBar.isTranslucent = true
        self.tabBarController?.tabBarController?.tabBar.backgroundColor = UIColor.clear
        self.tabBarController?.tabBarController?.view.backgroundColor = UIColor.clear
        self.tabBarController?.tabBarController?.view.isHidden = true
        
        self.loginButton.layer.cornerRadius = 8
        self.loginButton.layer.masksToBounds = true
        self.loginButton.layer.borderColor = UIColor.white.cgColor
        self.loginButton.setTitleColor(.white, for: .normal)
        self.loginButton.setTitle("Login", for: .normal)
        // TODO: - controll button state if new or existing user
    }
    
    
    func updateViews() {
        guard let currentUser = self.currentUser else { return }
        self.profileImageView.image = currentUser.photo
        self.loginButton.layer.cornerRadius = loginButton.layer.frame.height / 2
        self.loginButton.layer.borderColor = UIColor.white.cgColor
        self.loginButton.layer.borderWidth = 2
        self.loginButton.layer.masksToBounds = true
    }
}

