//
//  StoreLoaderTests.swift
//  InAppPurchaseTests
//
//  Created by Vinicius Moreira Leal on 08/03/2021.
//

import InAppPurchase
import StoreKit
import XCTest

class StoreLoaderTests: XCTestCase {
    
    func test_init_doesNotLoadProducts() {
        let request = ProductsRequestSpy()
        let sut = StoreLoader(request: { _ in
            request
        })
        
        XCTAssertTrue(request.messages.isEmpty)
    }
    
    // MARK: - Helpers
    
    private class ProductsRequestSpy: SKProductsRequest {
        enum Message {
            case start
        }
        
        private(set) var messages = [Message]()
        
        override func start() {
            messages.append(.start)
        }
    }
}
