//
//  Extensions.swift
//  Messenger
//
//  Created by Sima Nerush on 11/10/22.
//

import UIKit

extension UIView {

  public var width: CGFloat {
    return self.frame.size.width
  }

  public var heigth: CGFloat {
    return self.frame.size.height
  }

  public var top: CGFloat {
    return self.frame.origin.y
  }

  public var bottom: CGFloat {
    return self.frame.size.height + self.frame.origin.y
  }

  public var left: CGFloat {
    return self.frame.origin.x
  }

  public var right: CGFloat {
    return self.frame.origin.x + width
  }
}

