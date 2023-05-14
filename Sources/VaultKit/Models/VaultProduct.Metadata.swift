//
//  VaultProduct.Metadata.swift
//  
//
//  Created by PEXAVC on 5/12/23.
//

import Foundation
import StoreKit

extension VaultProduct {
    public struct Metadata: Identifiable, Equatable, Codable {
        
        public let id: String
        public let displayName: String
        public let displayPrice: String
        public let displaySubscriptionPeriod: String
        public let displayPromo: String
        public let isRenewable: Bool
        public let isPurchased: Bool
        
        init(_ vaultProduct: VaultProduct, isPurchased: Bool = false) {
            self.id = vaultProduct.id
            self.displayName = vaultProduct.product?.displayName ?? ""
            self.displayPrice = vaultProduct.product?.displayPrice ?? ""
            self.isRenewable = vaultProduct.kind == .renewable
            self.isPurchased = isPurchased
            
            switch vaultProduct.product?.subscription?.subscriptionPeriod .unit {
            case .year:
                displaySubscriptionPeriod = "/year"
            case .month:
                displaySubscriptionPeriod = "/month"
            case .week:
                displaySubscriptionPeriod = "/week"
            default:
                displaySubscriptionPeriod = ""
            }
            
            //TODO: account for more than 1 promo case
            if let promotionalOffers = vaultProduct.product?.subscription?.promotionalOffers,
               let firstOffer = promotionalOffers.first {
                
                if firstOffer.price == .zero {
                    displayPromo = "w/ a \(firstOffer.period.value) day free trial."
                } else {
                    displayPromo = "\(firstOffer.displayPrice) for \(firstOffer.period.value) day\(firstOffer.period.value > 1 ? "s" : "")."
                }
                
            } else {
                displayPromo = ""
            }
        }
        
        public static var empty: Metadata {
            .init(.init("", kind: .unknown))
        }
    }
    
    public var metadata: Metadata {
        .init(self)
    }
}
