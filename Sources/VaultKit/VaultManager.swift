//
//  VaultManager.swift
//  
//
//  Created by PEXAVC on 5/12/23.
//

import Foundation
import SwiftUI
import Combine

public class VaultManager: ObservableObject, Codable {
    public static let shared: VaultManager = .init()
    
    internal var cancellables = Set<AnyCancellable>()
    
    let kit: VaultKit
    
    @Published public var isSubscribed: Bool = false
    @Published public var hasPurchases: Bool = false
    
    init(_ products: [VaultProduct] = []) {
        self.kit = .init(products)
        observe()
    }
    
    init(_ kit: VaultKit) {
        self.kit = kit
        observe()
    }
    
    private func observe() {
        kit.$isSubscribed
            .removeDuplicates()
            .sink { [weak self] newValue in
                
                print("[VaultManager] isSubscribed Changed: \(newValue)")
                DispatchQueue.main.async {
                    self?.isSubscribed = newValue
                    self?.objectWillChange.send()
                }
            }.store(in: &cancellables)
        
        kit.$hasPurchases
            .removeDuplicates()
            .sink { [weak self] newValue in
                
                print("[VaultManager] hasPurchases Changed: \(newValue)")
                DispatchQueue.main.async {
                    self?.hasPurchases = newValue
                    self?.objectWillChange.send()
                }
            }.store(in: &cancellables)
        kit.observe()
    }
    
    @discardableResult
    public func load(_ products: [VaultProduct]) -> VaultManager {
        kit.load(products)
        return self
    }
    
    @discardableResult
    public static func load(_ products: [VaultProduct]) -> VaultManager {
        return VaultManager.shared.load(products)
    }
    
    enum CodingKeys: CodingKey {
        case kit
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(kit, forKey: .kit)
    }
    
    public required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kit = try container.decode(VaultKit.self, forKey: .kit)
        
        self.init(kit)
    }
}

extension VaultManager {
    public func purchase(_ product: VaultProduct) {
        kit.purchase(product.id)
    }
    
    public static func purchase(_ product: VaultProduct) {
        VaultManager.shared.purchase(product.id)
    }
    
    public func purchase(_ id: String) {
        kit.purchase(id)
    }
    
    public static func purchase(_ id: String) {
        VaultManager.shared.purchase(id)
    }
    
    public func purchase(_ item: any VaultProductIterable) {
        kit.purchase(item)
    }
    
    public static func purchase(_ item: any VaultProductIterable) {
        VaultManager.shared.purchase(item)
    }
    
    public func restore() {
        kit.restorePurchases()
    }
    
    public static func restore() {
        VaultManager.shared.restore()
    }
    
    public func checkSubscription() {
        kit.checkProducts()
    }
    
    public static func checkSubscription() {
        VaultManager.shared.checkSubscription()
    }
    
    public func isPurchased(_ item: any VaultProductIterable) -> Bool {
        kit.isPurchased(item)
    }
    
    public static func isPurchased(_ item: any VaultProductIterable) -> Bool {
        VaultManager.shared.isPurchased(item)
    }
    
    public func metadata(_ item: any VaultProductIterable) -> VaultProduct.Metadata {
        kit.metadata(item)
    }
    
    public static func metadata(_ item: any VaultProductIterable) -> VaultProduct.Metadata {
        VaultManager.shared.kit.metadata(item)
    }
}

extension VaultManager: Equatable {
    public static func == (lhs: VaultManager, rhs: VaultManager) -> Bool {
        lhs.kit.id == rhs.kit.id
    }
}

extension VaultManager {
    public var description: String {
        """
        ------------- [VaultManager] -----------------
        \(kit.productDescription)
        ---------------------------------------- //end
        """
    }
    
    public var purchaseDescription: String {
        """
        ------------- [VaultManager] -----------------
        \(kit.productPurchasedDescription)
        ---------------------------------------- //end
        """
    }
}
