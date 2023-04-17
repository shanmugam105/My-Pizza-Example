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

struct MainItem {
    let price: Double
    let title: String
    var type: ProductSize
    let icon: String
    // Original price
    var originalPrice: Double { (Double(type.rawValue) + 1.0) * price }
}

final class PizzaViewModel {
    // Items
    var mainItem: MainItem?
    var addonItems: [AddonItem] = []
    
    func getProductDetails(completion: @escaping (()->Void)) {
        DispatchQueue.global().async {[weak self] in
            self?.mainItem = .init(price: 1000.0, title: "Apple Pizza", type: .medium, icon: "pizza_full")
            let items: [AddonItem] = [.init(price: 10, title: "Peproni", selected: true, icon: "peproni"),
                                      .init(price: 5, title: "Onion", selected: false, icon: "onion"),
                                      .init(price: 12, title: "Mushroom", selected: false, icon: "mushroom"),
                                      .init(price: 7, title: "Cheese", selected: false, icon: "cheese")]
            self?.addonItems.append(contentsOf: items)
            completion()
        }
    }
}


final class PizzaViewController: UIViewController {
    private lazy var previousProductIndex: Int = productSizeSegmentedView.selectedSegmentIndex
    @IBOutlet weak var cartButton: UIButton!
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
                let mainItem = self?.viewModel.mainItem
                self?.updateMainPrice()
                self?.productTitleLabel.text = mainItem?.title
                self?.productImageView.image = UIImage(named: mainItem?.icon ?? "pizza_full")
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
        productTitleLabel.text = .none // "Apple Pizza"
        productPriceLabel.text = .none // "₹ 1000"
        productImageView.image = .none // UIImage(named: "pizza_full")
        // Segmented control
        productSizeSegmentedView.addTarget(self, action: #selector(productSizeUpdated), for: .valueChanged)
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
    }
    
    @objc private func submitButtonTapped() {
        animateMainProductToCart()
        viewModel.addonItems.enumerated().forEach { i, item in
            if item.selected {
                self.animateAddonProductToCart(index: i)
            }
        }
    }
    
    private func animateAddonProductToCart(index: Int) {
        let indexPath = IndexPath(item: index, section: 0)
        let cell = addonCollectionView.cellForItem(at: indexPath) as! AddonCollectionViewCell
        let copyProduct: UIImageView = cell.addonImageView.copyViewAndAdd(to: self.view)
        moveProductToCartCenter(item: copyProduct, cartView: self.cartButton)
    }
    
    private func animateMainProductToCart() {
        let copyProduct: UIImageView = productImageView.copyViewAndAdd(to: self.view)
        moveProductToCartCenter(item: copyProduct, cartView: self.cartButton)
    }
    
    private func moveProductToCartCenter(item: UIImageView, cartView: UIView) {
        submitButton.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {[weak self] in
            item.updateSizeScaleTo(x: 0.01, y: 0.01)
            UIView.animate(withDuration: 1) {
                item.center = cartView.center
                self?.view.layoutIfNeeded()
            } completion: { _ in
                item.removeFromSuperview()
                self?.submitButton.isUserInteractionEnabled = true
            }
        }
    }
    
    @objc private func productSizeUpdated(_ sender: UISegmentedControl) {
        // Rotate animation
        let clockWise: Bool = previousProductIndex < sender.selectedSegmentIndex
        self.productImageView.rotate(clockWise: clockWise)
        let itemSize: ProductSize = .init(rawValue: sender.selectedSegmentIndex) ?? .medium
        self.productImageView.updateSizeScale(to: itemSize)
        self.previousProductIndex = sender.selectedSegmentIndex
        // Calculate price
        var mainItemPrice = self.viewModel.mainItem
        mainItemPrice?.type = itemSize
        self.viewModel.mainItem = mainItemPrice
        updateMainPrice()
    }
    
    private func updateMainPrice() {
        let mainItemPrice = self.viewModel.mainItem?.originalPrice ?? 0.0
        let addonPrice = viewModel.addonItems.filter(\.selected).map{ $0.price }.reduce(0, { $0 + $1})
        let totalPrice = mainItemPrice + addonPrice
        self.productPriceLabel.text = totalPrice.asCurrency()
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
        var addonItem = viewModel.addonItems[indexPath.item]
        addonItem.selected.toggle()
        viewModel.addonItems[indexPath.item] = addonItem
        updateMainPrice()
        addonCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 80, height: 80)
    }
}

fileprivate extension UIImageView {
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
