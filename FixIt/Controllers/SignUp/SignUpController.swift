//
//  SignUpController.swift
//  FixIt
//
//  Created by Josiah Agosto on 10/31/19.
//  Copyright © 2019 Josiah Agosto. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class SignUpController: UIViewController, LocationNameProtocol {
    // References / Properties
    public lazy var signUpView = SignUpView()
    private lazy var locationManager = LocationManager.shared
    private lazy var customerHome = CustomerViewController()
    private lazy var employeeHome = EmployeeViewController()
    private let globalHelper = GlobalHelper.shared
    private let mapHelper = MapHelperFunctions()
    private var localIsCustomer: Bool = true
    // MARK: - Lifecycle
    override func loadView() {
        view = signUpView
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.startLocating()
    }
    
    
    private func setup() {
        navigationController?.navigationBar.topItem?.titleView = signUpView.registerLabel
        signUpView.registerButton.addTarget(self, action: #selector(createSpecifiedUser(sender:)), for: .touchUpInside)
        signUpView.employeeSwitch.addTarget(self, action: #selector(signedInWithEmployee(sender:)), for: .valueChanged)
        signUpView.cityField.addTarget(self, action: #selector(showMapView(sender:)), for: .touchUpInside)
        signUpView.accountHolderButton.addTarget(self, action: #selector(accountHolderAction(sender:)), for: .touchUpInside)
    }
    

    func userEnteredLocation(forString: String) {
        signUpView.cityField.setTitle(forString, for: .normal)
    }
    
    // MARK: - Actions
    @objc private func signedInWithEmployee(sender: UISwitch) {
        signUpView.isExpanded = !sender.isOn
        switch sender.isOn {
        case true:
            Constants.isCustomer = false
            signUpView.cityField.isEnabled = true
            signUpView.cityField.isHidden = false
            signUpView.employeeSkill.isEnabled = true
            signUpView.employeeSkill.isHidden = false
        case false:
            Constants.isCustomer = true
            signUpView.cityField.isEnabled = false
            signUpView.cityField.isHidden = true
            signUpView.employeeSkill.isEnabled = false
            signUpView.employeeSkill.isHidden = true
        }
    }
    
    
    @objc private func createSpecifiedUser(sender: UIButton) {
        createUser()
    }
    

    @objc private func showMapView(sender: UIButton) {
        let placesController = PlacesSearchController()
        self.navigationController?.present(placesController, animated: true)
    }
    

    @objc private func accountHolderAction(sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: - Private Functions
    private func createAtSignUpDate() -> String {
        let signUpDate = Date()
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .long
        formatter.string(from: signUpDate)
        return formatter.string(from: signUpDate)
    }
    
    
    private func createUser() {
        guard let email = signUpView.emailField.text, let password = signUpView.passwordField.text, let name = signUpView.nameField.text, let location = mapHelper.userLocationName, let skill = signUpView.employeeSkill.text, let state = mapHelper.userState else {
            // TODO: Add error controller here
            self.globalHelper.globalError(with: "Sign Up Error", and: "All fields must be filled in.") { (controller) in
                DispatchQueue.main.async {
                    self.present(controller, animated: true, completion: nil)
                }
            }
            errorOccurred()
            return
        }
        // Create User
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            guard let uid = Auth.auth().currentUser?.uid else { print(ValidationError.RetrievingUser.errorDescription!); return }
            if let error = error {
                self.globalHelper.globalError(with: "Error Creating User", and: error.localizedDescription) { (alertController) in
                    DispatchQueue.main.async {
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
                self.errorOccurred()
            } else {
                switch self.localIsCustomer {
                case true:
                    // Customer
                    self.createCustomer(with: uid, with: name, with: email)
                case false:
                    // Employee
                    self.createEmployee(with: uid, with: name, with: email, with: location, with: skill, and: state)
                } // Switch End
            }
        } // Auth End
    } // Func End
    
    
    private func createCustomer(with uid: String, with name: String, with email: String) {
        Constants.isCustomer = true
        let customerReference = Constants.dbReference.child("Users").child("byId").child(uid)
        let customerValues = ["name": name, "email": email.convertForbiddenFirebaseSymbols(from: email), "signedUp": self.createAtSignUpDate(), "isCustomer": self.localIsCustomer, "issueCounter": 0] as [String : Any]
        customerReference.updateChildValues(customerValues) { (error, _) in
            if error != nil {
                self.globalHelper.globalError(with: "Error Creating User", and: error!.localizedDescription) { (alertController) in
                    DispatchQueue.main.async {
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
                self.errorOccurred()
            } else {
                Constants.loggedIn = true
                DataRetriever().saveSetting(for: Constants.loggedIn, forKey: "logInKey")
                self.navigationController?.show(self.customerHome, sender: self)
            }
        }
    }
    
    
    private func createEmployee(with uid: String, with name: String, with email: String, with location: String, with skill: String, and state: String) {
        Constants.isCustomer = false
        let employeeReference = Constants.dbReference.child("Users").child("byId").child(uid)
        let employeeValues = ["name": name, "email": email.convertForbiddenFirebaseSymbols(from: email), "location": location, "skill": skill, "state": state, "signedUp": self.createAtSignUpDate(), "isCustomer": self.localIsCustomer] as [String : Any]
        employeeReference.updateChildValues(employeeValues) { (error, _) in
            if error != nil {
                self.globalHelper.globalError(with: "Error Creating User", and: error!.localizedDescription) { (alertController) in
                    DispatchQueue.main.async {
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
                self.errorOccurred()
            } else {
                Constants.loggedIn = true
                DataRetriever().saveSetting(for: Constants.loggedIn, forKey: "logInKey")
                self.navigationController?.show(self.employeeHome, sender: self)
            }
        }
    }
    
    
    private func errorOccurred() {
        self.signUpView.errorLabel.isHidden = false
        self.signUpView.errorLabel.text = UserError.UpdatingValues.errorDescription
        Constants.loggedIn = false
        DataRetriever().saveSetting(for: Constants.loggedIn, forKey: "logInKey")
    }
} // Class End


// MARK: - Location Error Delegate
extension SignUpController: ErrorControllerProtocol {
    func locationErrorController(with title: String, and description: String) {
        mapHelper.locationRequestError(with: title, and: description) { (controller) in
            DispatchQueue.main.async {
                self.present(controller, animated: true)
            }
        }
    }
}