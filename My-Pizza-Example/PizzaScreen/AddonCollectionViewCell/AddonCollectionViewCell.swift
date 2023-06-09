//
//  AddonCollectionViewCell.swift
//  My-Pizza-Example
//
//  Created by Sparkout on 12/04/23.
//

import UIKit

class AddonCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var addonTitleLabel: UILabel!
    @IBOutlet weak var addonImageView: UIImageView!
    func configureCell(for addon: AddonItem) {
        addonTitleLabel.text = addon.title + " - \(addon.price)"
        addonImageView.image = UIImage(named: addon.icon)
        addonImageView.backgroundColor = .clear
        containerView.backgroundColor = addon.selected ? .lightGray.withAlphaComponent(0.4) : .white
    }
}
