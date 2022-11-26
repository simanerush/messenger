//
//  LoginViewController.swift
//  Messenger
//
//  Created by Sima Nerush on 11/9/22.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn
import Firebase

class LoginViewController: UIViewController {
  
  private let scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    return scrollView
  }()
  
  private let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "logo")
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  private let emailField: UITextField = {
    let field = UITextField()
    field.autocapitalizationType = .none
    field.autocorrectionType = .no
    field.returnKeyType = .continue
    field.layer.cornerRadius = 12
    field.layer.borderWidth = 1
    field.layer.borderColor = UIColor.lightGray.cgColor
    field.placeholder = "email..."
    
    field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
    field.leftViewMode = .always
    field.backgroundColor = .white
    return field
  }()
  
  private let passwordField: UITextField = {
    let field = UITextField()
    field.autocapitalizationType = .none
    field.autocorrectionType = .no
    field.returnKeyType = .done
    field.layer.cornerRadius = 12
    field.layer.borderWidth = 1
    field.layer.borderColor = UIColor.lightGray.cgColor
    field.placeholder = "password..."
    
    field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
    field.leftViewMode = .always
    field.backgroundColor = .white
    field.isSecureTextEntry = true
    return field
  }()
  
  private let loginButton: UIButton = {
    let button = UIButton()
    button.setTitle("log in", for: .normal)
    button.backgroundColor = accentColor
    button.setTitleColor(.white, for: .normal)
    button.layer.cornerRadius = 12
    button.layer.masksToBounds = true
    button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
    return button
  }()
  
  private let facebookLogInButton: FBLoginButton = {
    let button = FBLoginButton()
    button.permissions = ["email", "public_profile"]
    return button
  }()
  
  private let googleLogInButton = GIDSignInButton()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "log in "
    view.backgroundColor = .white
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "register",
                                                        style: .done,
                                                        target: self,
                                                        action: #selector(didTapRegister))
    
    loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
    googleLogInButton.addTarget(self, action: #selector(didTapGoogleLoginButton), for: .touchUpInside)
    
    // filling out email and password will lead to login action
    emailField.delegate = self
    passwordField.delegate = self
    facebookLogInButton.delegate = self
    
    // add subviews
    view.addSubview(scrollView)
    scrollView.addSubview(imageView)
    scrollView.addSubview(emailField)
    scrollView.addSubview(passwordField)
    scrollView.addSubview(loginButton)
    
    facebookLogInButton.center = view.center
    scrollView.addSubview(facebookLogInButton)
    scrollView.addSubview(googleLogInButton)
    
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    scrollView.frame = view.bounds
    
    let size = scrollView.width / 3
    
    imageView.frame = CGRect(x: (scrollView.width - size) / 2,
                             y: 20,
                             width: size,
                             height: size)
    emailField.frame = CGRect(x: 30,
                              y: imageView.bottom + 10,
                              width: scrollView.width - 60,
                              height: 52)
    passwordField.frame = CGRect(x: 30,
                                 y: emailField.bottom + 10,
                                 width: scrollView.width - 60,
                                 height: 52)
    loginButton.frame = CGRect(x: 30,
                               y: passwordField.bottom + 10,
                               width: scrollView.width - 60,
                               height: 52)
    facebookLogInButton.frame = CGRect(x: 30,
                                       y: loginButton.bottom + 10,
                                       width: scrollView.width - 60,
                                       height: 52)
    googleLogInButton.frame = CGRect(x: 30, y: facebookLogInButton.bottom + 10, width: scrollView.width - 60, height: 52)
  }
  
  @objc private func didTapLoginButton() {
    
    // if the keyboard is on emailField
    emailField.resignFirstResponder()
    passwordField.resignFirstResponder()
    
    guard let email = emailField.text, let password = passwordField.text, !email.isEmpty, !password.isEmpty, password.count >= 6 else {
      alertUserLoginError()
      return
    }
    
    // weak self is needed for not causing a retention cycle when a view is dismissed
    FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] authResult, error in
      guard let strongSelf = self else {
        return
      }
      
      guard let result = authResult, error == nil else {
        print("failed to log in user with email \(email)!")
        return
      }
      
      let user = result.user
      print("logged in \(user)")
      strongSelf.navigationController?.dismiss(animated: true, completion: nil)
    })
  }
  
  @objc private func didTapRegister() {
    let vc = RegisterViewController()
    vc.title = "Create Account"
    navigationController?.pushViewController(vc, animated: true)
  }
  
  @objc private func didTapGoogleLoginButton() {
    guard let clientID = FirebaseApp.app()?.options.clientID else { return }

    // Create Google Sign In configuration object.
    let config = GIDConfiguration(clientID: clientID)

    // Start the sign in flow!
    GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { user, error in
      
      if let error = error {
        print("failed to sign in with google \(error)")
        return
      }

      guard
        let authentication = user?.authentication,
        let idToken = authentication.idToken
      else {
        return
      }
      
      guard let user = user else { return }
      
      print("did sign in with google \(user)")
      
      guard let email = user.profile?.email,
            let firstName = user.profile?.givenName,
            let lastName = user.profile?.familyName else {
        print("failed to parse google user's data")
        return
      }
      
      DatabaseManager.shared.userExists(with: email) { exists in
        if !exists {
          DatabaseManager.shared.insertUser(with: ChatAppUser(firstName: firstName, lastName: lastName, emailAddress: email))
        }
      }

      let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                     accessToken: authentication.accessToken)
      
      // finish the sign in flow by signing in with firebase
      FirebaseAuth.Auth.auth().signIn(with: credential, completion: { [weak self] authResult, error in
        guard let strongSelf = self else {
          return
        }
        
        guard authResult != nil, error == nil else {
          if let error = error {
            print("google credential login failed, MFA may be needed - \(error)")
          }
          return
        }
        print("successfully logged in with google!")
        strongSelf.navigationController?.dismiss(animated: true, completion: nil)
      })
    }
  }
  
  func alertUserLoginError(message: String = "please enter all information to log in") {
    let alert = UIAlertController(title: "🚨error!", message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "dismiss", style: .cancel, handler: nil))
    present(alert, animated: true)
  }
}

extension LoginViewController: UITextFieldDelegate {
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    
    if textField == emailField {
      passwordField.becomeFirstResponder()
    }
    else if textField == passwordField {
      didTapLoginButton()
    }
    return true
  }
}

extension LoginViewController: LoginButtonDelegate {
  func loginButtonDidLogOut(_ loginButton: FBSDKLoginKit.FBLoginButton) {
    // no operation
  }
  
  func loginButton(_ loginButton: FBSDKLoginKit.FBLoginButton, didCompleteWith result: FBSDKLoginKit.LoginManagerLoginResult?, error: Error?) {
    guard let token = result?.token?.tokenString else {
      print("user failed to log in with facebook")
      return
    }
    
    let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me", parameters: ["fields": "email, name"], tokenString: token, version: nil, httpMethod: .get)
    facebookRequest.start(completion: { connection, result, error in
      guard let result = result as? [String: Any], error == nil else {
        print("failed to maike facebook graph request")
        return
      }
      
      guard let userName = result["name"] as? String,
            let email = result["email"] as? String else {
        print("failed to get email and name from fb result")
        return
      }
      
      let nameComponents = userName.components(separatedBy: " ")
      guard nameComponents.count == 2 else {
        return
      }
      
      let firstName = nameComponents[0]
      let lastName = nameComponents[1]
      
      DatabaseManager.shared.userExists(with: email, completion:  { exists in
        // add new user to the database.
        if !exists {
          DatabaseManager.shared.insertUser(with: ChatAppUser(firstName: firstName, lastName: lastName, emailAddress: email))
        }
      })
      let credential = FacebookAuthProvider.credential(withAccessToken: token)
      
      FirebaseAuth.Auth.auth().signIn(with: credential, completion: { [weak self] authResult, error in
        guard let strongSelf = self else {
          return
        }
        
        guard authResult != nil, error == nil else {
          if let error = error {
            print("facebook credential login failed, MFA may be needed - \(error)")
          }
          return
        }
        print("successfully logged in!")
        strongSelf.navigationController?.dismiss(animated: true, completion: nil)
      })
    })
  }
}
