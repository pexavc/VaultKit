//
//  VaultActiveProduct.swift
//  
//
//  Created by PEXAVC on 5/12/23.
//

import Foundation

public struct VaultActiveProduct: Equatable, Codable {
    public let expirationDate: Date?
    public let purchaseDate: Date
    public let isRenewable: Bool
}
