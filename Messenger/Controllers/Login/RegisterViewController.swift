//
//  RegisterViewController.swift
//  Messenger
//
//  Created by Sima Nerush on 11/9/22.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {

  private let scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    return scrollView
  }()

  private let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(systemName: "person.fill")
    imageView.tintColor = .gray
    imageView.contentMode = .scaleAspectFit
    imageView.layer.masksToBounds = true
    imageView.layer.borderWidth = 2
    imageView.layer.borderColor = UIColor.lightGray.cgColor
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

  private let firstNameField: UITextField = {
    let field = UITextField()
    field.autocapitalizationType = .none
    field.autocorrectionType = .no
    field.returnKeyType = .continue
    field.layer.cornerRadius = 12
    field.layer.borderWidth = 1
    field.layer.borderColor = UIColor.lightGray.cgColor
    field.placeholder = "first name..."

    field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
    field.leftViewMode = .always
    field.backgroundColor = .white
    return field
  }()

  private let lastNameField: UITextField = {
    let field = UITextField()
    field.autocapitalizationType = .none
    field.autocorrectionType = .no
    field.returnKeyType = .continue
    field.layer.cornerRadius = 12
    field.layer.borderWidth = 1
    field.layer.borderColor = UIColor.lightGray.cgColor
    field.placeholder = "last name..."

    field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
    field.leftViewMode = .always
    field.backgroundColor = .white
    return field
  }()

  private let registerButton: UIButton = {
    let button = UIButton()
    button.setTitle("register", for: .normal)
    button.backgroundColor = .systemYellow
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

    // filling out email and password will lead to login action
    emailField.delegate = self
    passwordField.delegate = self

    // add subviews
    view.addSubview(scrollView)
    scrollView.addSubview(imageView)
    scrollView.addSubview(firstNameField)
    scrollView.addSubview(lastNameField)
    scrollView.addSubview(emailField)
    scrollView.addSubview(passwordField)
    scrollView.addSubview(registerButton)

    imageView.isUserInteractionEnabled = true
    scrollView.isUserInteractionEnabled = true

    let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangeProfilePic))
    imageView.addGestureRecognizer(gesture)
    
    registerButton.addTarget(self, action: #selector(didTapRegisterButton), for: .touchUpInside)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    scrollView.frame = view.bounds

    let size = scrollView.width / 3

    imageView.frame = CGRect(x: (scrollView.width - size) / 2,
                             y: 20,
                             width: size,
                             height: size)

    imageView.layer.cornerRadius = imageView.width / 2.0

    firstNameField.frame = CGRect(x: 30,
                              y: imageView.bottom + 10,
                              width: scrollView.width - 60,
                              height: 52)
    lastNameField.frame = CGRect(x: 30,
                                 y: firstNameField.bottom + 10,
                                 width: scrollView.width - 60,
                                 height: 52)
    emailField.frame = CGRect(x: 30,
                              y: lastNameField.bottom + 10,
                              width: scrollView.width - 60,
                              height: 52)
    passwordField.frame = CGRect(x: 30,
                                 y: emailField.bottom + 10,
                                 width: scrollView.width - 60,
                                 height: 52)
    registerButton.frame = CGRect(x: 30,
                               y: passwordField.bottom + 10,
                               width: scrollView.width - 60,
                               height: 52)
  }

  @objc private func didTapRegisterButton() {
    emailField.resignFirstResponder()
    passwordField.resignFirstResponder()
    firstNameField.resignFirstResponder()
    lastNameField.resignFirstResponder()

    guard let firstName = firstNameField.text, let lastName = lastNameField.text, let email = emailField.text, let password = passwordField.text, !firstName.isEmpty, !lastName.isEmpty, !email.isEmpty, !password.isEmpty, password.count >= 6 else {
      alertUserLoginError()
      return
    }

    // Firebase log in
    FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { authResult, error in
      guard let result = authResult, error == nil else {
        print("error creating user")
        return
      }
      
      let user = result.user
      print("created uesr:\(user)")
    })
  }

  @objc private func didTapChangeProfilePic() {
    presentPhotoActionSheet()
  }

  func alertUserLoginError() {
    let alert = UIAlertController(title: "🚨error!", message: "please enter all information to register", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "dismiss", style: .cancel, handler: nil))
    present(alert, animated: true)
  }
}

extension RegisterViewController: UITextFieldDelegate {

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {

    if textField == emailField {
      passwordField.becomeFirstResponder()
    }
    else if textField == passwordField {
      didTapRegisterButton()
    }
    return true
  }

}

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

  func presentPhotoActionSheet() {
    let actionSheet = UIAlertController(title: "profile picture", message: "how would you like to select a picture?", preferredStyle: .actionSheet)
    actionSheet.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
    actionSheet.addAction(UIAlertAction(title: "📸take photo", style: .default, handler: { [weak self] _ in
      self?.presentCamera()
    }))
    actionSheet.addAction(UIAlertAction(title: "🎞️choose photo", style: .default, handler: { [weak self] _ in
      self?.presentPhotoPicker()
    }))

    present(actionSheet, animated: true )
  }

  func presentCamera() {
    let vc = UIImagePickerController()
    vc.sourceType = .camera
    vc.delegate = self
    vc.allowsEditing = true
    present(vc, animated: true)
  }

  func presentPhotoPicker() {
    let vc = UIImagePickerController()
    vc.sourceType = .photoLibrary
    vc.delegate = self
    vc.allowsEditing = true
    present(vc, animated: true)
  }

  internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    picker.dismiss(animated: true, completion: nil)
    // get edited image
    guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }

    self.imageView.image = selectedImage
  }

  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion: nil)
  }
}
