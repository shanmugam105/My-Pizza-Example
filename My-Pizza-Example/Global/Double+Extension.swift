//
//  Double+Extension.swift
//  My-Pizza-Example
//
//  Created by Sparkout on 17/04/23.
//

import Foundation

extension Double {
    func asCurrency(trailing: Bool = false) -> String {
        return trailing ? (String(self) + " ₹") : ("₹ " + String(self))
    }
}
