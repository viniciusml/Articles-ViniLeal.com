//
//  ProductRequestFactoryTests.swift
//  InAppPurchaseTests
//
//  Created by Vinicius Moreira Leal on 18/03/2021.
//

import InAppPurchase
import StoreKit
import XCTest

class ProductRequestFactoryTests: XCTestCase {
    
    func test_adapter_createsProperRequest() {
        let identifiers = ["id1", "id2"]
        
        _ = ProductRequestFactory.make(
            with: identifiers,
            request: { mappedIdentifiers in
                
                XCTAssertTrue(mappedIdentifiers.isSubset(of: identifiers))
                return ProductsRequestSpy.any
            })
    }
}
