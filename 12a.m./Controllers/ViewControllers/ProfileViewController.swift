//
//  ProfileViewController.swift
//  12a.m.
//
//  Created by Nick Reichard on 11/20/17.
//  Copyright © 2017 Nick Reichard. All rights reserved.
//

import UIKit
import CoreLocation

class ProfileViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    
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
    private let locationManager = CLLocationManager()
    private let locator = Locator.self
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.currentCityLabel.text = "\(TimeZone.current)"
        
        updateViews()
        setUpAppearance()
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
        updateUserInfo()
    }
    
    // MARK: - Update
    @objc private func updateViews() {
        guard let user = self.currentUser,
            let userPhoto = self.currentUser?.photo else { return }
        DispatchQueue.main.async {
            
            self.usernameLabel.text = user.username
            self.profileImageView.image = userPhoto
            self.usernameTextField.text = "  \(user.username)"
            self.emailTextField.text = "  \(user.email)"
            self.currentCityLabel.font = UIFont.systemFont(ofSize: 20.0, weight: .thin)
        }
        
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
    
    private func updateUserInfo() {
        guard let userName = usernameTextField.text, userName != "", let email = emailTextField.text, email != "", let profileImage = profileImageView.image else { return }
        
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
        } else {
            UserController.shared.updateCurrentUser(username: userName, email: email, completion: { (success) in
                if !success {
                    print("Not successfull updating existing user")
                } else {
                    print("Updated user!")
                    self.updateViews()
                }
                
            })
        }
    }
    
    
    private func updateDiscription() {
        
        let posts = PostController.shared.posts.map {$0.ownerReference}
        if posts.count != 0 {
            discriptionLabel.text = "Posted \(posts.count) times at 12am - 1am"
        }
    }
}

extension ProfileViewController {
    
    // MARK: - Location
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = manager.location else { return }
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            if (error != nil) {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }
            if (placemarks?.count)! > 0 {
                
                print("placemarks",placemarks ?? 0)
                let pm = placemarks?[0]
                self.displayLocationInfo(pm)
            } else {
                print("Problem with the data received from geocoder")
            }
        })
    }
    
    func displayLocationInfo(_ placemark: CLPlacemark?) {
        if let containsPlacemark = placemark {
            
            print("your location is:-",containsPlacemark)
            //stop updating location to save battery life
            locationManager.stopUpdatingLocation()
            let locality = (containsPlacemark.locality != nil) ? containsPlacemark.locality : ""
            let country = (containsPlacemark.country != nil) ? containsPlacemark.country : ""
            let state = (containsPlacemark.administrativeArea != nil) ? containsPlacemark.administrativeArea : ""
            
            let unitedStates = "United States"
            if (country?.contains(unitedStates))! {
                self.currentCountryLabel.text = "U.S.A"
            } else {
                self.currentCountryLabel.text = country
            }
            self.currentCityLabel.text = locality
            self.currentStateLabel.text = state
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while updating location " + error.localizedDescription)
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
