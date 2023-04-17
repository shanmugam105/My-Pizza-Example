//
//  PizzaModel.swift
//  My-Pizza-Example
//
//  Created by Sparkout on 17/04/23.
//

import Foundation

enum ProductSize: Int {
    case small
    case medium
    case large
}

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
