//
//  LoginViewController.swift
//  Messenger
//
//  Created by Sima Nerush on 11/9/22.
//

import UIKit

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

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "log in "
    view.backgroundColor = .white

    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "register",
                                                       style: .done,
                                                       target: self,
                                                       action: #selector(didTapRegister))

    loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)

    // filling out email and password will lead to login action
    emailField.delegate = self
    passwordField.delegate = self

    // add subviews
    view.addSubview(scrollView)
    scrollView.addSubview(imageView)
    scrollView.addSubview(emailField)
    scrollView.addSubview(passwordField)
    scrollView.addSubview(loginButton)
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
  }

  @objc private func didTapLoginButton() {

    // if the keyboard is on emailField
    emailField.resignFirstResponder()
    passwordField.resignFirstResponder()

    guard let email = emailField.text, let password = passwordField.text, !email.isEmpty, !password.isEmpty, password.count >= 6 else {
      alertUserLoginError()
      return
    }

    // TODO: firebase log in
  }

  @objc private func didTapRegister() {
    let vc = RegisterViewController()
    vc.title = "Create Account"
    navigationController?.pushViewController(vc, animated: true)
  }

  func alertUserLoginError() {
    let alert = UIAlertController(title: "🚨error!", message: "please enter all information to log in", preferredStyle: .alert)
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