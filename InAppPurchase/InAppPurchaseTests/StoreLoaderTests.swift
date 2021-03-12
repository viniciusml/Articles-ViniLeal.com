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
        var requestSpy: ProductsRequestSpy!
        let sut = StoreLoaderAdapter(identifiers: identifiers, factory: {
            requestSpy = ProductsRequestSpy(productIdentifiers: $0)
            return requestSpy
        })
        
        _ = sut.createRequest()
        
        XCTAssertTrue(requestSpy.identifiers.isSubset(of: identifiers))
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

class ProductsRequestSpy: Request {
    enum Message {
        case start
    }
    
    var delegate: SKProductsRequestDelegate?
    
    private(set) var messages = [Message]()
    private(set) var identifiers = Set<String>()
    
    required init(productIdentifiers: Set<String> = Set()) {
        identifiers.formUnion(productIdentifiers)
    }
    
    func start() {
        messages.append(.start)
    }
}
