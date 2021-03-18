//
//  PaymentTransactionObserverTests.swift
//  InAppPurchaseTests
//
//  Created by Vinicius Moreira Leal on 28/01/2021.
//

import InAppPurchase
import StoreKit
import XCTest

class PaymentTransactionObserverTests: XCTestCase {
    
    func test_buy_addsPaymentRequestToQueue() {
        let (queue, sut) = makeSUT()
        
        let product = TestProduct(identifier: "a product")
        sut.buy(product)
        
        XCTAssertEqual(queue.messages, [.add])
        XCTAssertEqual(queue.addedProducts, ["a product"])
    }
    
    func test_restore_restoresCompletedTransactionsToQueue() {
        let (queue, sut) = makeSUT()
        
        sut.restore()
        
        XCTAssertEqual(queue.messages, [.restore])
    }
    
    func test_updatedTransactions_purchasingOrDeferred_doNotMessageQueue() {
        let (queue, sut) = makeSUT()
        
        sut.paymentQueue(queue, updatedTransactions: [.purchasing, .deferred])
        
        XCTAssertTrue(queue.messages.isEmpty)
    }
    
    func test_updatedTransactions_purchased_messagesQueue() {
        let (queue, sut) = makeSUT()
        
        sut.paymentQueue(queue, updatedTransactions: [.purchased])
        
        XCTAssertEqual(queue.messages, [.finish])
    }
    
    func test_updatedTransactions_failed_messagesQueue() {
        let (queue, sut) = makeSUT()
        
        sut.paymentQueue(queue, updatedTransactions: [.failed])
        
        XCTAssertEqual(queue.messages, [.finish])
    }
    
    func test_updatedTransactions_restored_messagesQueue() {
        let (queue, sut) = makeSUT()
        
        sut.paymentQueue(queue, updatedTransactions: [.restored])
        
        XCTAssertEqual(queue.messages, [.finish])
    }
    
    // MARK: Helpers
    
    private func makeSUT() -> (PaymentQueueSpy, PaymentTransactionObserver) {
        let queue = PaymentQueueSpy()
        let sut = PaymentTransactionObserver(queue: queue)
        return (queue, sut)
    }
    
    private class PaymentQueueSpy: SKPaymentQueue {
        enum Message {
            case add, restore, finish
        }
        
        private(set) var messages = [Message]()
        private(set) var addedProducts = [String]()
 
        override func add(_ payment: SKPayment) {
            messages.append(.add)
            addedProducts.append(payment.productIdentifier)
        }
        
        override func restoreCompletedTransactions() {
            messages.append(.restore)
        }
        
        override func finishTransaction(_ transaction: SKPaymentTransaction) {
            messages.append(.finish)
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

extension SKPaymentTransaction {
    static let purchasing = makeTestTransaction(.purchasing)
    static let deferred = makeTestTransaction(.deferred)
    static let purchased = makeTestTransaction(.purchased)
    static let failed = makeTestTransaction(.failed)
    static let restored = makeTestTransaction(.restored)
    
    private static func makeTestTransaction(_ state: SKPaymentTransactionState) -> SKPaymentTransaction {
        TestTransaction(state: state)
    }
    
    private class TestTransaction: SKPaymentTransaction {
        
        let state: SKPaymentTransactionState
        
        init(state: SKPaymentTransactionState) {
            self.state = state
        }
        
        override var transactionState: SKPaymentTransactionState {
            state
        }
    }
}
