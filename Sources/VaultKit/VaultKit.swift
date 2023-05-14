//
//  VaultKit.swift
//  
//
//  Created by PEXAVC on 5/12/23.
//

import Foundation
import Combine
import StoreKit

class VaultKit: ObservableObject, Codable {
    public let id: UUID
    
    internal var lastUpdate: Date = .init()
    
    internal var products: [String : VaultProduct]
    internal var productOrdering: [String]
    internal var purchasedProductIDs = Set<String>() {
        didSet {
            lastUpdate = .init()
            
            isSubscribed = purchasedProductIDs.isEmpty == false
        }
    }
    
    private var loadingTask: Task<(), Error>? = nil
    internal var purchaseTask: Task<(), Error>? = nil
    internal var restoreTask: Task<(), Error>? = nil
    internal var isLoaded: Bool = false
    
    @Published var isSubscribed: Bool = false
    @Published var currentPurchase: VaultActiveProduct? = nil
    
    init(_ products: [VaultProduct], id: UUID = .init()) {
        self.id = id
        self.productOrdering = products.map { $0.id }
        self.products = VaultKit.load(products)
    }
    
    enum CodingKeys: CodingKey {
        case id
        case products
        case lastUpdate
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(id, forKey: .id)
        try? container.encode(products, forKey: .products)
        try? container.encode(lastUpdate, forKey: .lastUpdate)
    }
    
    public required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try? container.decode(UUID.self, forKey: .id)
        let restoredProducts = try? container.decode([String : VaultProduct].self, forKey: .products)
        let lastUpdate = try? container.decode(Date.self, forKey: .lastUpdate)
        
        self.init([], id: id ?? .init())
        
        guard let products = restoredProducts else { return }
        
        self.lastUpdate = lastUpdate ?? self.lastUpdate
        
        self.load(Array(products.values))
    }
    
    func load(_ products: [VaultProduct]) {
        guard self.isLoaded == false else { return }
        
        self.productOrdering = products.map { $0.id }
        self.products = VaultKit.load(products)
        
        self.loadingTask?.cancel()
        self.loadingTask = nil
        self.loadingTask = Task { [weak self] in
            guard let this = self else { return }
            
            let products = try? await Product.products(for: Array(this.products.keys))
            
            for product in products ?? [] {
                this.products[product.id]?.load(product)
            }
            
            this.isLoaded = true
        }
    }
    
    private static func load(_ products: [VaultProduct]) -> [String : VaultProduct] {
        products.reduce(into: [String : VaultProduct]()) {
            $0[$1.id] = $1
        }
    }
}

extension VaultKit: Equatable {
    static func == (lhs: VaultKit, rhs: VaultKit) -> Bool {
        lhs.id == rhs.id
    }
}

extension VaultKit {
    public var productDescription: String {
        """
        \(products.values.map { $0.description }.joined(separator: "\n"))
        """
    }
    
    public var productPurchasedDescription: String {
        """
        [VaultKit] -----------------------
        Purchased Product IDs:
        
        \(purchasedProductIDs.joined(separator: "\n"))
        ------------------------------//end
        """
    }
}
