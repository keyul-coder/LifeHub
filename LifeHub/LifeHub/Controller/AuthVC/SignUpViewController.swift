//
//  SignUpViewController.swift
//  LifeHub
//
//  Created by Smit Patel on 2025-01-19.
//

import UIKit
import FirebaseAuth

class SignUpViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var backToLoginButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTextFields()
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
        
        confirmPasswordTextField.layer.cornerRadius = 8
        confirmPasswordTextField.layer.borderWidth = 1
        confirmPasswordTextField.layer.borderColor = UIColor.systemGray4.cgColor
    }
    
    private func setupTextFields() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        
        // Add padding to text fields
        let textFields = [emailTextField, passwordTextField, confirmPasswordTextField]
        textFields.forEach { textField in
            textField?.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textField?.frame.height ?? 0))
            textField?.leftViewMode = .always
        }
    }
    
    // MARK: - IBActions
    @IBAction func createAccountTapped(_ sender: UIButton) {
        guard validateInputs() else { return }
        
        showLoadingState(true)
        
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!
        
        // Firebase User Registration
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.showLoadingState(false)
                
                if let error = error {
                    self?.showAlert(title: "Sign Up Failed", message: error.localizedDescription)
                    return
                }
                
                // Account created successfully - navigate to main app
                if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                    sceneDelegate.showMainApp()
                }
            }
        }
    }
    
    @IBAction func backToLoginTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
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
        
        guard let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            showAlert(title: "Error", message: "Please confirm your password")
            return false
        }
        
        guard isValidEmail(email) else {
            showAlert(title: "Error", message: "Please enter a valid email address")
            return false
        }
        
        guard password.count >= 6 else {
            showAlert(title: "Error", message: "Password must be at least 6 characters long")
            return false
        }
        
        guard password == confirmPassword else {
            showAlert(title: "Error", message: "Passwords do not match")
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
        createAccountButton.isEnabled = !isLoading
        createAccountButton.setTitle(isLoading ? "Creating Account..." : "Create Account", for: .normal)
        createAccountButton.alpha = isLoading ? 0.7 : 1.0
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            confirmPasswordTextField.becomeFirstResponder()
        } else if textField == confirmPasswordTextField {
            textField.resignFirstResponder()
            createAccountTapped(createAccountButton)
        }
        return true
    }
}
