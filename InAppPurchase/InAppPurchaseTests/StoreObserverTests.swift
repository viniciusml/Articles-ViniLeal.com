//
//  StoreObserverTests.swift
//  InAppPurchaseTests
//
//  Created by Vinicius Moreira Leal on 28/01/2021.
//

import InAppPurchase
import StoreKitTest
import XCTest

class StoreObserverTests: XCTestCase {
    
    func test_buy_addsPaymentRequestToQueue() {
        let queue = PaymentQueueSpy()
        let sut = StoreObserver(queue: queue)
        
        let product = TestProduct()
        sut.buy(product)
        
        XCTAssertEqual(queue.messages, [.add])
    }
    
    // MARK: Helpers
    
    private class PaymentQueueSpy: SKPaymentQueue {
        enum Message {
            case add
        }
        
        private(set) var messages = [Message]()
        
        override func add(_ payment: SKPayment) {
            messages.append(.add)
        }
    }
    
    private class TestProduct: SKProduct {
        override var productIdentifier: String {
            "test product"
        }
    }
}
