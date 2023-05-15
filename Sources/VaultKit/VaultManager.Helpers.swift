//
//  VaultManager.Helpers.swift
//  
//
//  Created by PEXAVC on 5/12/23.
//

import Foundation

extension VaultManager {
    public static var isSubscribed: Bool {
        VaultManager.shared.isSubscribed
    }
    
    public var currentPurchase: VaultActiveProduct? {
        kit.currentPurchase
    }
    
    public static var currentPurchase: VaultActiveProduct? {
        VaultManager.shared.currentPurchase
    }
    
    public var products: [VaultProduct] {
        Array(kit.products.values)
    }
    
    public var renewableProducts: [VaultProduct] {
        products.filter { $0.kind == .renewable }
    }
    
    public var nonRenewableProducts: [VaultProduct] {
        products.filter { $0.kind == .nonRenewable }
    }
    
    public static var products: [VaultProduct] {
        Array(VaultManager.shared.kit.products.values)
    }
    
    public static var renewableProducts: [VaultProduct] {
        VaultManager.shared.products.filter { $0.kind == .renewable }
    }
    
    public static var nonRenewableProducts: [VaultProduct] {
        VaultManager.shared.products.filter { $0.kind == .nonRenewable }
    }
    
    public func productFor(_ product: any VaultProductIterable) -> VaultProduct? {
        kit.products[product.id]
    }
}

extension Collection where Self.Element == VaultProduct {
    public var asMetadata: [VaultProduct.Metadata] {
        self.map { $0.metadata }
    }
}

extension Collection where Self.Element == VaultProduct {
    public var ordered: [VaultProduct] {
        var orderedProducts: [VaultProduct] = []
        
        let ids: [String] = VaultManager.shared.kit.productOrdering.filter { id in
            self.contains(where: { $0.id ==  id})
        }
        
        guard var mutableProducts: [VaultProduct] = self as? [VaultProduct] else {
            return self as? [VaultProduct] ?? []
        }
        
        for id in ids {
            if let index = mutableProducts.firstIndex(where: { $0.id == id }) {
                orderedProducts.append(mutableProducts.remove(at: index))
            }
        }
        
        return orderedProducts
    }
}
