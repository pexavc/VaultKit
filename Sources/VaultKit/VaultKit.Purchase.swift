//
//  VaultKit.Purchase.swift
//  
//
//  Created by PEXAVC on 5/12/23.
//

import Foundation
import Combine
import StoreKit

extension VaultKit {
    
    func purchase(_ id: String) {
        if let vaultProduct = self.products[id] {
            self.purchaseTask?.cancel()
            self.purchaseTask = Task { [weak self] in
                let result = try? await vaultProduct.product?.purchase()
                switch result {
                    
                case let .success(.verified(transaction)):
                    
                    self?.purchasedProductIDs.insert(transaction.productID)
                    await transaction.finish()
                    self?.setCurrentPurchase(transaction, willRenew: nil)
                    
                case let .success(.unverified(transaction, error)):
                    
                    self?.purchasedProductIDs.remove(transaction.productID)
                    await transaction.finish()
                    self?.checkProducts()
                    
                case .pending:
                    
                    break
                    
                case .userCancelled:
                    self?.checkProducts()
                    
                    break
                    
                @unknown default:
                    
                    break
                    
                }
            }
        }
    }
    
    func purchase(_ item: any VaultProductIterable) {
        self.purchase(item.id)
    }
    
    func checkProducts() {
        self.checkProductsTask = Task { [weak self] in
            guard let products = self?.products.values else {
                return
            }
            
            var statuses: [StoreKit.Product.SubscriptionInfo.Status : String] = [:]
            
            for vaultProduct in products {
                if let subscription = vaultProduct.product?.subscription {
                    if let newStatuses = try? await subscription.status,
                       let status = newStatuses.first {
                        
                        
                        statuses[status] = vaultProduct.id
                    }
                }
            }
            
            let validSubscriptions: [StoreKit.Product.SubscriptionInfo.Status] = Array(statuses.keys).filter { $0.state == .subscribed }
            
            var verifiedTransactions: [Transaction:Bool] = [:]
            
            for validSubscription in validSubscriptions {
                if let productID = statuses[validSubscription] {
                    
                    guard case .verified(let transaction) = validSubscription.transaction else {
                        return
                    }
                    
                    guard case .verified(let info) = validSubscription.renewalInfo else {
                        return
                    }
                    
                    
                    verifiedTransactions[transaction] = info.willAutoRenew
                    self?.purchasedProductIDs.insert(productID)
                }
            }
            
            //TODO: allow for a collection of Verified Active Products
            if let firstTransaction = (verifiedTransactions).keys.first {
                self?.setCurrentPurchase(firstTransaction, willRenew: verifiedTransactions[firstTransaction])
            }
            
            print(productPurchasedDescription)
        }
    }
    
    func restorePurchases() {
        self.purchaseTask?.cancel()
        self.restoreTask?.cancel()
        
        self.restoreTask = Task { [weak self] in
            for await result in Transaction.currentEntitlements {
                
                guard case .verified(let transaction) = result else {
                    continue
                }
                
                if transaction.revocationDate != nil {
                    self?.purchasedProductIDs.remove(transaction.productID)
                }
                
                await transaction.finish()
            }
            
            print(productPurchasedDescription)
        }
    }
    
    func setCurrentPurchase(_ transaction: Transaction, willRenew: Bool?) {
        if let product = self.products[transaction.productID] {
            
            self.currentPurchase = .init(expirationDate: transaction.expirationDate,
                                         purchaseDate: transaction.purchaseDate,
                                         isRenewable: willRenew ?? (product.kind == .renewable))
        }
    }
}
