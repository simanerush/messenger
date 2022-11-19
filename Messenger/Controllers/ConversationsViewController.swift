//
//  ConversationsViewController.swift
//  Messenger
//
//  Created by Sima Nerush on 11/9/22.
//

import UIKit
import FirebaseAuth

class ConversationsViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .red
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    validateAuth()
  }
  
  private func validateAuth() {
    if FirebaseAuth.Auth.auth().currentUser == nil {
      let vc = LoginViewController()
      let nav = UINavigationController(rootViewController: vc)
      // to prevent dismissing the login screen
      nav.modalPresentationStyle = .fullScreen
      present(nav, animated: false)
    }
  }
}

