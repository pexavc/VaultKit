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

                    await transaction.finish()
                    
                    self?.purchasedProductIDs.insert(transaction.productID)
                    
                    print(productPurchasedDescription)

                case let .success(.unverified(transaction, error)):

                    self?.purchasedProductIDs.remove(transaction.productID)

                case .pending:

                    break

                case .userCancelled:

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
    
    func restorePurchases() {
        self.purchaseTask?.cancel()
        self.restoreTask?.cancel()
        self.restoreTask = Task { [weak self] in
            for await result in Transaction.currentEntitlements {

                guard case .verified(let transaction) = result else {

                    continue

                }


                if transaction.revocationDate == nil {
                    if let product = self?.products[transaction.productID] {
                        
                        self?.currentPurchase = .init(expirationDate: transaction.expirationDate,
                                                      purchaseDate: transaction.purchaseDate,
                                                      isRenewable: product.kind == .renewable)
                        
                        self?.purchasedProductIDs.insert(transaction.productID)
                    }

                } else {

                    self?.purchasedProductIDs.remove(transaction.productID)

                }
            }
            print(productPurchasedDescription)
        }
    }
}
