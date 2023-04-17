//
//  PizzaViewModel.swift
//  My-Pizza-Example
//
//  Created by Sparkout on 17/04/23.
//

import Foundation

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
    
    func selectAddonProduct(for index: Int) {
        var addonItem = addonItems[index]
        addonItem.selected.toggle()
        addonItems[index] = addonItem
    }
    
    func getUpdatedPrice() -> Double {
        let mainItemPrice = mainItem?.originalPrice ?? 0.0
        let addonPrice = addonItems.filter(\.selected).map{ $0.price }.reduce(0, { $0 + $1})
        let totalPrice = mainItemPrice + addonPrice
        return totalPrice
    }
}
