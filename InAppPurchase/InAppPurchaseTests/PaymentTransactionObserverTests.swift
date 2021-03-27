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
    
    func test_init_addsObserverToQueue() {
        let (queue, sut) = makeSUT()
        
        XCTAssertTrue(queue.transactionObservers.first === sut)
    }
    
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
        XCTAssertNil(sut.completion)
    }
    
    func test_updatedTransactions_purchased_messagesQueue() {
        let (queue, sut) = makeSUT()
        let identifier = "a product identifier"
        
        expect(sut, toCompleteWith: .make(.purchased, with: identifier), when: {
            sut.paymentQueue(queue, updatedTransactions: [.purchased(identifier: identifier)])
        })
        
        XCTAssertEqual(queue.messages, [.finish])
    }
    
    func test_updatedTransactions_failed_messagesQueue() {
        let (queue, sut) = makeSUT()
        let identifier = "a failed product identifier"
        let error = NSError(domain: "test error", code: 0)
        
        expect(sut, toCompleteWith: .make(.failed, with: identifier), when: {
            sut.paymentQueue(queue, updatedTransactions: [.failed(error: error, identifier: identifier)])
        })
        
        XCTAssertEqual(queue.messages, [.finish])
    }
    
    func test_updatedTransactions_failedWithCancellation_doesNotMessageQueue() {
        let (queue, sut) = makeSUT()
        let identifier = "a failed product identifier"
        let error = NSError(domain: "test error", code: SKError.paymentCancelled.rawValue)
        
        expect(sut, toNotCompleteWhen: {
            sut.paymentQueue(queue, updatedTransactions: [.failed(error: error, identifier: identifier)])
        })
        
        XCTAssertTrue(queue.messages.isEmpty)
    }
    
    func test_updatedTransactions_restoredWithOriginal_messagesQueue() {
        let (queue, sut) = makeSUT()
        let identifier = "a restored product identifier"
        
        expect(sut, toCompleteWith: .make(.restored, with: identifier), when: {
            sut.paymentQueue(queue, updatedTransactions: [.restored(originalIdentifier: identifier)])
        })
        
        XCTAssertEqual(queue.messages, [.finish])
    }
    
    func test_updatedTransactions_restoredWithoutOriginal_doesNotMessageQueue() {
        let (queue, sut) = makeSUT()
        
        expect(sut, toNotCompleteWhen: {
            sut.paymentQueue(queue, updatedTransactions: [.restored(originalIdentifier: nil)])
        })
        
        XCTAssertTrue(queue.messages.isEmpty)
    }
    
    // TODO: Restore
    
    // MARK: Helpers
    
    private func makeSUT() -> (PaymentQueueSpy, PaymentTransactionObserver) {
        let queue = PaymentQueueSpy()
        let sut = PaymentTransactionObserver(queue: queue)
        return (queue, sut)
    }
    
    private func expect(_ sut: PaymentTransactionObserver, toCompleteWith expectedTransaction: PaymentTransaction, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait for completion")
        var receivedTransaction: PaymentTransaction?
        
        sut.completion = {
            receivedTransaction = $0
            exp.fulfill()
            XCTAssertEqual(receivedTransaction, expectedTransaction)
        }
        action()
        
        wait(for: [exp], timeout: 0.1)
    }
    
    private func expect(_ sut: PaymentTransactionObserver, toNotCompleteWhen action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        sut.completion = {
            XCTFail("SUT should not complete, completed with: \($0) instead", file: file, line: line)
        }
        action()
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
    static func purchased(identifier: String) -> SKPaymentTransaction { makeTestTransaction(.purchased, identifier: identifier)
    }
    static func failed(error: Error, identifier: String) -> SKPaymentTransaction {
        makeTestTransaction(.failed, identifier: identifier, error: error)
    }
    static func restored(originalIdentifier: String?) -> SKPaymentTransaction {
        makeTestTransaction(.restored, originalIdentifier: originalIdentifier)
    }
    
    private static func makeTestTransaction(
        _ state: SKPaymentTransactionState,
        identifier: String = "test id",
        originalIdentifier: String? = nil,
        error: Error? = nil) -> SKPaymentTransaction
    {
        TestTransaction(stubbedState: state, stubbedProductIdentifier: identifier, stubbedOriginalIdentifier: originalIdentifier, stubbedError: error)
    }
    
    private class TestTransaction: SKPaymentTransaction {
        
        private let stubbedState: SKPaymentTransactionState
        private let stubbedOriginalIdentifier: String?
        private let stubbedProductIdentifier: String
        private let stubbedError: Error?
        
        init(stubbedState: SKPaymentTransactionState,
             stubbedProductIdentifier: String,
             stubbedOriginalIdentifier: String?,
             stubbedError: Error?) {
            self.stubbedState = stubbedState
            self.stubbedProductIdentifier = stubbedProductIdentifier
            self.stubbedOriginalIdentifier = stubbedOriginalIdentifier
            self.stubbedError = stubbedError
        }
        
        override var transactionState: SKPaymentTransactionState {
            stubbedState
        }
        
        override var error: Error? {
            stubbedError
        }
        
        override var original: SKPaymentTransaction? {
            guard let identifier = stubbedOriginalIdentifier else { return nil }
            return TestTransaction(stubbedState: .restored, stubbedProductIdentifier: identifier, stubbedOriginalIdentifier: identifier, stubbedError: nil)
        }
        
        override var payment: SKPayment {
            SKPayment(product: FakeProduct(fakeProductIdentifier: stubbedProductIdentifier))
        }
    }
}
