//
//  StoreLoaderTests.swift
//  InAppPurchaseTests
//
//  Created by Vinicius Moreira Leal on 08/03/2021.
//

import InAppPurchase
import StoreKit
import XCTest

class StoreLoaderAdapterTests: XCTestCase {
    
    func test_adapter_createsProperRequest() {
        let identifiers = ["id1", "id2"]
        
        _ = StoreLoaderFactory.make(
            with: identifiers,
            request: { mappedIdentifiers in
                
                XCTAssertTrue(mappedIdentifiers.isSubset(of: identifiers))
                return ProductsRequestSpy.any
            })
    }
}

class StoreLoaderTests: XCTestCase {

    func test_init_setsDelegate() {
        let request = ProductsRequestSpy()
        let sut = StoreLoader(request: request)

        XCTAssertTrue(request.delegate === sut)
    }
    
    func test_fetchProducts_startsRequest() {
        let request = ProductsRequestSpy()
        let sut = StoreLoader(request: request)
        
        sut.fetchProducts()
        
        XCTAssertEqual(request.messages, [.start])
    }
}

class ProductsRequestSpy: SKProductsRequest {
    enum Message {
        case start
    }
    
    private(set) var messages = [Message]()
    private(set) var identifiers = Set<String>()
    
    override init(productIdentifiers: Set<String> = Set()) {
        identifiers = productIdentifiers
        super.init()
    }
    
    override func start() {
        messages.append(.start)
    }
}

extension ProductsRequestSpy {
    static var any: ProductsRequestSpy {
        ProductsRequestSpy(productIdentifiers: Set<String>())
    }
}
