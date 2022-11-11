//
//  ConversationsViewController.swift
//  Messenger
//
//  Created by Sima Nerush on 11/9/22.
//

import UIKit

class ConversationsViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .red
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    let isLoggedIn = UserDefaults.standard.bool(forKey: "logged_in")

    if !isLoggedIn {
      let vc = LoginViewController()
      let nav = UINavigationController(rootViewController: vc)
      // to prevent dismissing the login screen
      nav.modalPresentationStyle = .fullScreen
      present(nav, animated: false)
    }
  }

}

