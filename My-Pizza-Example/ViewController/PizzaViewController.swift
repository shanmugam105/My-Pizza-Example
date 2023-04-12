//
//  PizzaViewController.swift
//  My-Pizza-Example
//
//  Created by Sparkout on 12/04/23.
//

import UIKit

enum ProductSize: Int {
    case small
    case medium
    case large
}

fileprivate typealias CollectionViewDelegate = UICollectionViewDelegate & UICollectionViewDelegateFlowLayout

struct AddonItem {
    let price: Double
    let title: String
    var selected: Bool
    let icon: String
}

final class PizzaViewModel {
    // Items
    var addonItems: [AddonItem] = []
    
    func getProductDetails(completion: @escaping (()->Void)) {
        DispatchQueue.global().async {
            let items: [AddonItem] = [.init(price: 10, title: "Peproni", selected: true, icon: "peproni"),
                                      .init(price: 5, title: "Onion", selected: false, icon: "onion"),
                                      .init(price: 12, title: "Mushroom", selected: false, icon: "mushroom"),
                                      .init(price: 7, title: "Cheese", selected: false, icon: "cheese")]
            self.addonItems.append(contentsOf: items)
            completion()
        }
    }
}


final class PizzaViewController: UIViewController {
    private lazy var previousProductIndex: Int = productSizeSegmentedView.selectedSegmentIndex
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productTitleLabel: UILabel!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var addonCollectionView: UICollectionView!
    @IBOutlet weak var productSizeSegmentedView: UISegmentedControl!
    let viewModel: PizzaViewModel = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        viewModel.getProductDetails { [weak self] in
            DispatchQueue.main.async {
                self?.addonCollectionView.reloadData()
            }
        }
    }
    
    private func configureView() {
        // Register addon view
        addonCollectionView.registerNib(AddonCollectionViewCell.self)
        addonCollectionView.delegate = self
        addonCollectionView.dataSource = self
        // Setup title
        productTitleLabel.text = "Apple Pizza"
        productPriceLabel.text = "₹ 1000"
        productImageView.image = UIImage(named: "pizza_full")
        // Segmented control
        productSizeSegmentedView.addTarget(self, action: #selector(productSizeUpdated), for: .valueChanged)
    }
    
    
    
    @objc private func productSizeUpdated(_ sender: UISegmentedControl) {
        let clockWise: Bool = previousProductIndex < sender.selectedSegmentIndex
        self.productImageView.rotate(clockWise: clockWise)
        let itemSize: ProductSize = .init(rawValue: sender.selectedSegmentIndex) ?? .medium
        self.productImageView.updateSize(to: itemSize)
        self.previousProductIndex = sender.selectedSegmentIndex
    }
}

extension PizzaViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.addonItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(AddonCollectionViewCell.self, indexPath: indexPath)
        let item = viewModel.addonItems[indexPath.row]
        cell.configureCell(for: item)
        return cell
    }
}

extension PizzaViewController: CollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var item = viewModel.addonItems[indexPath.item]
        item.selected.toggle()
        viewModel.addonItems[indexPath.item] = item
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 80, height: 80)
    }
}

fileprivate extension UIImageView {
    func updateSize(to size: ProductSize) {
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
}
