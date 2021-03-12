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

//class StoreLoaderTests: XCTestCase {
//
//    func test_init_doesNotLoadProducts() {
//        let request = ProductsRequestSpy()
//        let sut = StoreLoader(request: { _ in
//            request
//        })
//
//        XCTAssertTrue(request.messages.isEmpty)
//    }
//}

class ProductsRequestSpy: Request {
    enum Message {
        case start
    }
    
    private(set) var messages = [Message]()
    private(set) var identifiers = Set<String>()
    
    required init(productIdentifiers: Set<String> = Set()) {
        identifiers.formUnion(productIdentifiers)
    }
    
    func start() {
        messages.append(.start)
    }
}
