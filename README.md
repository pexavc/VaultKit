# VaultKit
StoreKit2 interface focused on on-device validation of renewables/non-renewables.

## Create StoreKit.config file

https://developer.apple.com/documentation/xcode/setting-up-storekit-testing-in-xcode

```
To create a StoreKit configuration file:

1. Launch Xcode, then choose File > New > File.

2. In the sheet that appears, enter storekit in the Filter search field.

3. Select StoreKit Configuration File, then click Next.

4. In the dialog, enter a name for the file. For a synced configuration file, select the checkbox, specify your team and app in the drop-down menus that appear, then click Next. For a local configuration, leave the checkbox unselected, then click Next.

5. Select a location, and click Create.

6. Save the file to your project.
```

## Create Products

Must inherit String AND `VaultProductIterable` for now, as the raw Representable just checks for such. Will make more generic.

```swift
import VaultKit

struct VaultProducts {
    enum Renewable: String, VaultProductIterable {
        case monthly = "...product_id..."
        
        var kind: VaultProductKind {
            .renewable
        }
    }
    
    enum NonRenewable: String, VaultProductIterable {
        case month = "...product_id..."
        case week = "...product_id..."
        case day = "...product_id..."
        
        var kind: VaultProductKind {
            .nonRenewable
        }
    }
}

```

## Load VaultManager
```swift
var manager = VaultManager
                        .load(
                            VaultProducts.Renewable.vaultProducts +
                            VaultProducts.NonRenewable.vaultProducts
                        )
```

## Purchase Product
```swift
manager.purchase(VaultProducts.Renewable.monthly)
```

## Restore Purchases
```swift
manager.restorePurchases()
```

## Check Purchase
```swift
manager.isPurchased(VaultProducts.Renewable.monthly)
```

## Retrieve Metadata
```swift
public struct Metadata {
    let displayName: String
    let displayPrice: String
    let isRenewable: Bool
    let isPurchased: Bool
}
```

```swift
manager.metadata(VaultProducts.Renewable.monthly)

//Statically available
VaultManager.metadata(VaultProducts.Renewable.monthly)
```

## Helpers

```swift
//VaultManager.swift

public var isSubscribed: Bool { get }

public var products: [VaultProduct] { get }

public var renewableProducts: [VaultProduct] { get }

public var nonRenewableProducts: [VaultProduct] { get }
```

```swift

//Preserves ordering of the enum that stores your products
manager.products.ordered 

//Returns the collection as Metadata objects, best for UI display cases
//Identifiable and Codable
manager.products.ordered.asMetadata
manager.products.asMetadata

```
