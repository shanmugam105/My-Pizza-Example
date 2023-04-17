//
//  UIImageView+Extension.swift
//  My-Pizza-Example
//
//  Created by Sparkout on 17/04/23.
//

import UIKit

extension UIImageView {
    func updateSizeScale(to size: ProductSize) {
        UIView.animate(withDuration: 1) {
            var scaleSize: CGFloat {
                switch size {
                case .small: return 0.5
                case .medium: return 1
                case .large: return 1.5
                }
            }
            self.transform = CGAffineTransform.identity.scaledBy(x: scaleSize, y: scaleSize)
        }
    }
    
    func updateSizeScaleTo(x: CGFloat, y: CGFloat) {
        UIView.animate(withDuration: 1) {
            self.transform = CGAffineTransform.identity.scaledBy(x: x, y: y)
        }
    }
}
