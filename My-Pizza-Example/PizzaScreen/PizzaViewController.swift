//
//  PizzaViewController.swift
//  My-Pizza-Example
//
//  Created by Sparkout on 12/04/23.
//

import UIKit

typealias CollectionViewDelegate = UICollectionViewDelegate & UICollectionViewDelegateFlowLayout

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
        getProductDetails()
    }
    
    private func getProductDetails() {
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
        // Update quantity
        viewModel.cartQuantity += 1
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
            guard let self else { return }
            item.updateSizeScaleTo(x: 0.01, y: 0.01)
            UIView.animate(withDuration: 1) {
                item.center = cartView.center
                self.view.layoutIfNeeded()
            } completion: { _ in
                item.removeFromSuperview()
                self.submitButton.isUserInteractionEnabled = true
                self.cartButton.addBadge(number: self.viewModel.cartQuantity)
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
        self.productPriceLabel.text = viewModel.getUpdatedPrice().asCurrency()
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
        viewModel.selectAddonProduct(for: indexPath.item)
        updateMainPrice()
        addonCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 80, height: 80)
    }
}
