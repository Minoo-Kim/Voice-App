//
//  SignUpViewController.swift
//  comm
//
//  Created by Minoo Kim on 11/13/21.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore

class SignUpViewController: UIViewController {
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var positionSwitch: UISwitch!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElements()
    }
    func setUpElements(){
        // Hide error label
        errorLabel.alpha=0;
        
        // Styling elements
        Utilities.styleTextField(firstNameTextField)
        Utilities.styleTextField(lastNameTextField)
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        // style switch?
    }
    // Check fields and validate data. If true return nil. If false returns error
    func validateFields()->String?{
        // Check that all fields are filled in
        if firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)=="" ||
            lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            return "Please fill in all fields."
        }
        
        //  Check if the password is secure
        let cleanedPassword=passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if Utilities.isPasswordValid(cleanedPassword)==false{
            return "Please make sure youer password is  at least 8 characters, contains a special character and a number"
        }
        return nil
    }
    @IBAction func signUpTapped(_ sender: Any) {
        // Validate the fields
        let error = validateFields()
        if error != nil {
            showError(message:error!)
        }
        else{
            // Store cleaned versions of the data
            let firstName = firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let lastName = lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            var position = true
            if (!positionSwitch.isOn) {
                position = false;
            }
            // Ceate the user
            Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
                // Check for  errors
                if err != nil {
                    // There was an error
                    self.showError(message:"Error creating user")
                }
                else{
                    let db = Firestore.firestore()
                    db.collection("users").document(result!.user.uid).setData(
                                                            ["firstname":firstName,
                                                              "lastname":lastName,
                                                              "uid": result!.user.uid,
                                                              "Doctor":position]) {(error) in
                        if error != nil {
                            // Show error message
                            self.showError(message:"Error saving user data")
                        }
                    }
                    // Transition to home screen
                    self.transitionToHome()
                }

            }
        }
    }
    func showError( message:String){
        errorLabel.text=message
        errorLabel.alpha=1
    }
    func transitionToHome(){
        let homeViewController =
        storyboard?.instantiateViewController(withIdentifier:
            Constants.Storyboard.homeViewController) as?
            HomeViewController
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()
    }

}


