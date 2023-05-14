//
//  VaultKit.Metadata.swift
//  
//
//  Created by PEXAVC on 5/12/23.
//

import Foundation

extension VaultKit {
    func isPurchased(_ item: any VaultProductIterable) -> Bool {
        purchasedProductIDs.contains(item.id)
    }
    
    func metadata(_ item: any VaultProductIterable) -> VaultProduct.Metadata {
        if let product = products[item.id] {
            return .init(product, isPurchased: self.isPurchased(item))
        } else {
            return .empty
        }
    }
}
