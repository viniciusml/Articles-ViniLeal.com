//
//  StoreObserverTests.swift
//  InAppPurchaseTests
//
//  Created by Vinicius Moreira Leal on 28/01/2021.
//  For end to end test: https://www.revenuecat.com/blog/storekit-testing-in-xcode

import InAppPurchase
import StoreKit
import XCTest

class StoreObserverTests: XCTestCase {
    
    func test_buy_addsPaymentRequestToQueue() {
        let queue = PaymentQueueSpy()
        let sut = StoreObserver(queue: queue)
        
        let product = TestProduct(identifier: "a product")
        sut.buy(product)
        
        XCTAssertEqual(queue.messages, [.add])
        XCTAssertEqual(queue.addedProducts, ["a product"])
    }
    
    // MARK: Helpers
    
    private class PaymentQueueSpy: SKPaymentQueue {
        enum Message {
            case add
        }
        
        private(set) var messages = [Message]()
        private(set) var addedProducts = [String]()
 
        override func add(_ payment: SKPayment) {
            messages.append(.add)
            addedProducts.append(payment.productIdentifier)
        }
    }
    
    private class TestProduct: SKProduct {
        
        let identifier: String
        
        init(identifier: String) {
            self.identifier = identifier
        }
        
        override var productIdentifier: String {
            identifier
        }
    }
}
