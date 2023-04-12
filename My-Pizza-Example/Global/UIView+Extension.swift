//
//  UIView+Extension.swift
//  My-Pizza-Example
//
//  Created by Sparkout on 12/04/23.
//

import UIKit

extension UIView {
    func rotate(clockWise: Bool = true, count: Int = 1) {
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: (clockWise ? Double.pi : -Double.pi) * 2)
        rotation.duration = 1
        rotation.isCumulative = true
        rotation.repeatCount = Float(count)
        self.layer.add(rotation, forKey: "rotationAnimation")
    }
}

