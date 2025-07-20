//
//  LoginViewController.swift
//  LifeHub
//
//  Created by Smit Patel on 2025-01-19.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTextFields()
        
        // Firebase is now configured and ready
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Configure text fields
        emailTextField.layer.cornerRadius = 8
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.borderColor = UIColor.systemGray4.cgColor
        
        passwordTextField.layer.cornerRadius = 8
        passwordTextField.layer.borderWidth = 1
        passwordTextField.layer.borderColor = UIColor.systemGray4.cgColor
    }
    
    private func setupTextFields() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        // Add padding to text fields
        emailTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: emailTextField.frame.height))
        emailTextField.leftViewMode = .always
        
        passwordTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: passwordTextField.frame.height))
        passwordTextField.leftViewMode = .always
    }
    
    // MARK: - IBActions
    @IBAction func loginTapped(_ sender: UIButton) {
        guard validateInputs() else { return }
        
        showLoadingState(true)
        
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!
        
        // Firebase Authentication
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.showLoadingState(false)
                
                if let error = error {
                    self?.showAlert(title: "Login Failed", message: error.localizedDescription)
                    return
                }
                
                // Login successful - navigate to main app
                if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                    sceneDelegate.showMainApp()
                }
            }
        }
    }
    
    @IBAction func signUpTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Auth", bundle: nil)
        if let signUpVC = storyboard.instantiateViewController(withIdentifier: "SignUpVC") as? SignUpViewController {
            navigationController?.pushViewController(signUpVC, animated: true)
        }
    }
    
    @IBAction func forgotPasswordTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Reset Password", message: "Enter your email address to reset your password", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Email"
            textField.keyboardType = .emailAddress
        }
        
        let resetAction = UIAlertAction(title: "Reset", style: .default) { [weak self] _ in
            guard let email = alert.textFields?.first?.text,
                  !email.isEmpty else {
                self?.showAlert(title: "Error", message: "Please enter a valid email address")
                return
            }
            
            // Firebase Password Reset
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.showAlert(title: "Error", message: error.localizedDescription)
                    } else {
                        self?.showAlert(title: "Success", message: "Password reset email sent successfully")
                    }
                }
            }
        }
        
        alert.addAction(resetAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    // MARK: - Helper Methods
    private func validateInputs() -> Bool {
        guard let email = emailTextField.text, !email.isEmpty else {
            showAlert(title: "Error", message: "Please enter your email")
            return false
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Error", message: "Please enter your password")
            return false
        }
        
        guard isValidEmail(email) else {
            showAlert(title: "Error", message: "Please enter a valid email address")
            return false
        }
        
        return true
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func showLoadingState(_ isLoading: Bool) {
        loginButton.isEnabled = !isLoading
        loginButton.setTitle(isLoading ? "Signing In..." : "Sign In", for: .normal)
        loginButton.alpha = isLoading ? 0.7 : 1.0
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            textField.resignFirstResponder()
            loginTapped(loginButton)
        }
        return true
    }
}
