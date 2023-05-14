//
//  VaultProduct.swift
//  
//
//  Created by PEXAVC on 5/12/23.
//

import Foundation
import StoreKit

public enum VaultProductKind: String, Hashable, Codable {
    case nonRenewable
    case renewable
    case unknown
}

public protocol AnyVaultProduct {
    var kind: VaultProductKind { get }
    var id: String { get }
}

public class VaultProduct: AnyVaultProduct, Identifiable, Codable {
    
    public let kind: VaultProductKind
    public let id: String
    private(set) var product: Product? = nil
    private(set) var isLoaded: Bool = false
    public var element: (any VaultProductIterable)? = nil
    
    init(_ vaultProductElement: any VaultProductIterable) {
        self.id = vaultProductElement.id
        self.kind = vaultProductElement.kind
        self.element = vaultProductElement
    }
    
    init(_ id: String, kind: VaultProductKind) {
        self.id = id
        self.kind = kind
    }
    
    func load(_ product: Product) {
        self.product = product
        self.isLoaded = true
    }
    
    enum CodingKeys: CodingKey {
        case id
        case kind
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(id, forKey: .id)
        try? container.encode(kind, forKey: .kind)
    }
    
    public required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try? container.decode(String.self, forKey: .id)
        let kind = try? container.decode(VaultProductKind.self, forKey: .kind)
        
        self.init(id ?? "", kind: kind ?? .unknown)
    }
}

extension VaultProduct: Equatable {
    public static func == (lhs: VaultProduct, rhs: VaultProduct) -> Bool {
        lhs.id == rhs.id
    }
}

extension VaultProduct {
    public var description: String {
        """
        [VaultProduct] -----------------
        id: \(id)
        kind: \(kind.rawValue)
        isLoaded: \(product != nil && isLoaded)
        price: \(product?.price ?? .zero)
        -------------------------- //end
        """
    }
}

public protocol VaultProductIterable: CaseIterable {
    var kind: VaultProductKind { get }
}

extension VaultProductIterable {
    static public var vaultProducts: [VaultProduct] {
        Self.allCases.map { .init($0) }
    }
    
    public var id: String {
        return ((self as? (any RawRepresentable))?.rawValue as? String) ?? ""
    }
}
