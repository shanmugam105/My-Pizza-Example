//
//  UICollectionView+Extension.swift
//  Enadhu-Unavagam
//
//  Created by Sparkout on 12/03/23.
//

import UIKit

protocol ReusableView: AnyObject { }

extension ReusableView where Self: UIView {
    static var identifier: String { return String(describing: self) }
}

protocol NibLoadableView: AnyObject { }

extension NibLoadableView where Self: UIView {
    static var nib: UINib { UINib(nibName: String(describing: self), bundle: .main) }
    static func loadView() -> UIView? { nib.instantiate(withOwner: nil).first as? UIView }
}

extension UICollectionViewCell: NibLoadableView, ReusableView { }

extension UICollectionView {
    func registerNib<T: UICollectionViewCell>(_ type: T.Type) {
        register(T.nib, forCellWithReuseIdentifier: T.identifier)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(_ type: T.Type, indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.identifier, for: indexPath) as? T else { return T() }
        return cell
    }
}
