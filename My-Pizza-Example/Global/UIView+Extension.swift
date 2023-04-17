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

extension UIView {
    func copyView<T: UIView>() -> T? {
        guard
            let data = try? NSKeyedArchiver.archivedData(withRootObject:self, requiringSecureCoding:false),
            let view = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data)
        else { return nil }
        return view as? T
    }
    
    @discardableResult
    func copyViewAndAdd<T: UIView>(to view: UIView) -> T {
        let copyProduct: UIImageView = copyView() ?? .init()
        copyProduct.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(copyProduct)
        NSLayoutConstraint.activate([
            copyProduct.topAnchor.constraint(equalTo: self.topAnchor),
            copyProduct.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            copyProduct.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            copyProduct.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
        return copyProduct as! T
    }
}
