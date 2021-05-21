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
    
    override func tearDown() {
        PaymentQueueSpy.resetState()
        super.tearDown()
    }
    
    func test_init_addsObserverToQueue() {
        let (queue, sut, _) = makeSUT()
        
        XCTAssertTrue(queue.transactionObservers.first === sut)
    }
    
    func test_buy_addsPaymentRequestToQueue() {
        let (queue, sut, _) = makeSUT()
        
        let product = TestProduct(identifier: "a product")
        sut.buy(product)
        
        XCTAssertEqual(queue.messages, [.add])
        XCTAssertEqual(queue.addedProducts, ["a product"])
    }
    
    func test_updatedTransactions_purchasingOrDeferred_doNotMessageQueue() {
        let (queue, sut, delegate) = makeSUT()
        
        expect(delegate, toNotCompleteWhen: {
            sut.paymentQueue(queue, updatedTransactions: [.purchasing, .deferred])
        })
        
        XCTAssertTrue(queue.messages.isEmpty)
    }
    
    func test_updatedTransactions_purchased_messagesQueue() {
        let (queue, sut, delegate) = makeSUT()
        let identifier = "a product identifier"
        
        expect(delegate, toCompleteWith: .make(.purchased, with: identifier), when: {
            sut.paymentQueue(queue, updatedTransactions: [.purchased(identifier: identifier)])
        })
        
        XCTAssertEqual(queue.messages, [.finish])
    }
    
    func test_updatedTransactions_failed_messagesQueue() {
        let (queue, sut, delegate) = makeSUT()
        let identifier = "a failed product identifier"
        let error = NSError(domain: "test error", code: 0)
        
        expect(delegate, toCompleteWith: .make(.failed, with: identifier), when: {
            sut.paymentQueue(queue, updatedTransactions: [.failed(error: error, identifier: identifier)])
        })
        
        XCTAssertEqual(queue.messages, [.finish])
    }
    
    func test_updatedTransactions_failedWithCancellation_doesNotMessageQueue() {
        let (queue, sut, delegate) = makeSUT()
        let identifier = "a failed product identifier"
        let error = NSError(domain: "test error", code: SKError.paymentCancelled.rawValue)
        
        expect(delegate, toNotCompleteWhen: {
            sut.paymentQueue(queue, updatedTransactions: [.failed(error: error, identifier: identifier)])
        })
        
        XCTAssertTrue(queue.messages.isEmpty)
    }
    
    func test_restore_doesNotCompleteWithNoTransactions() {
        PaymentQueueSpy.stubbCompletedTransactions([
            .restored(originalIdentifier: nil)
        ])
        let (_, sut, delegate) = makeSUT()
        
        expect(delegate, toNotCompleteWhen: sut.restore)
    }
    
    func test_restore_withoutOriginalIdentifier_doesNotMessageQueue() {
        PaymentQueueSpy.stubbCompletedTransactions([
            .restored(originalIdentifier: nil)
        ])
        let (queue, sut, _) = makeSUT()
        
        sut.restore()
        
        XCTAssertEqual(queue.messages, [.restore])
    }
    
    func test_restore_withMultipleTransactions_completesWithSuccess() {
        let transactions = makeRestoredTransactions("1", "2", "3")
        PaymentQueueSpy.stubbCompletedTransactions(transactions.sk)
        let (queue, sut, delegate) = makeSUT()
        
        expect(delegate, toCompleteWith: .success(transactions.domain), when: sut.restore)
        
        XCTAssertEqual(queue.messages, [.restore, .finish, .finish, .finish])
    }
    
    func test_restore_twiceWithDifferentValues_completesWithSuccess() {
        let transactions = makeRestoredTransactions("1", "2", "3")
        PaymentQueueSpy.stubbCompletedTransactions(transactions.sk)
        let (_, sut, delegate) = makeSUT()
        
        expect(delegate, toCompleteWith: .success(transactions.domain), when: sut.restore)
        
        let newTransactions = makeRestoredTransactions("4", "5", "6")
        PaymentQueueSpy.stubbCompletedTransactions(newTransactions.sk)
        
        expect(delegate, toCompleteWith: .success(newTransactions.domain), when: sut.restore)
    }
    
    func test_restore_withError_completesWithFailure() {
        let error = NSError(domain: "test error", code: 0)
        PaymentQueueSpy.stubbError(error)
        let (_, sut, delegate) = makeSUT()
        
        expect(delegate, toCompleteWith: .failure(error), when: sut.restore)
    }
    
    // MARK: Helpers
    
    private func makeSUT() -> (PaymentQueueSpy, PaymentTransactionObserver, PaymentTransactionObserverDelegateSpy) {
        let queue = PaymentQueueSpy()
        let sut = PaymentTransactionObserver(queue: queue)
        let delegate = PaymentTransactionObserverDelegateSpy()
        sut.delegate = delegate
        return (queue, sut, delegate)
    }
    
    private func makeRestoredTransactions(_ identifiers: String?...) -> (sk: [SKPaymentTransaction], domain: [PaymentTransaction]) {
        let skTransactions = identifiers.map { SKPaymentTransaction.restored(originalIdentifier: $0) }
        let domainTransactions = identifiers.map { PaymentTransaction.make(.restored, with: $0 ?? "") }
        return (skTransactions, domainTransactions)
    }
    
    private func expect(_ delegate: PaymentTransactionObserverDelegateSpy, toCompleteWith expectedTransaction: PaymentTransaction, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        action()
        var receivedTransaction: PaymentTransaction?
        
        let result = delegate.result!
        if let transactions = try? result.get() {
            receivedTransaction = transactions.first
        }
        
        XCTAssertEqual(receivedTransaction, expectedTransaction)
    }
    
    private func expect(_ delegate: PaymentTransactionObserverDelegateSpy, toCompleteWith expectedResult: PaymentTransactionObserver.TransactionResult, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        action()
        
        let receivedResult = delegate.result!
        switch (receivedResult, expectedResult) {
        case (.success(let receivedTransactions), .success(let expectedTransactions)):
            XCTAssertEqual(receivedTransactions, expectedTransactions, file: file, line: line)
        case (.failure(let receivedError as NSError), .failure(let expectedError as NSError)):
            XCTAssertEqual(receivedError, expectedError, file: file, line: line)
        default:
            XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
        }
    }
    
    private func expect(_ delegate: PaymentTransactionObserverDelegateSpy, toNotCompleteWhen action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        action()
        
        XCTAssertNil(delegate.result, file: file, line: line)
    }
    
    private class PaymentTransactionObserverDelegateSpy: PaymentTransactionObserverDelegate {
        private var results: [TransactionResult] = []
        
        var result: TransactionResult? {
            results.last
        }
        
        func didUpdateTransactions(with result: TransactionResult) {
            results.append(result)
        }
    }
    
    private class PaymentQueueSpy: SKPaymentQueue {
        enum Message {
            case add, restore, finish
        }
        
        private(set) var messages = [Message]()
        private(set) var addedProducts = [String]()
        private(set) static var completedTransactions = [SKPaymentTransaction]()
        private(set) static var completionError: Error?
        
        static func stubbCompletedTransactions(_ transactions: [SKPaymentTransaction]) {
            completedTransactions = transactions
        }
        
        static func stubbError(_ error: Error) {
            completionError = error
        }
        
        static func resetState() {
            completedTransactions = []
            completionError = nil
        }
 
        override func add(_ payment: SKPayment) {
            messages.append(.add)
            addedProducts.append(payment.productIdentifier)
        }
        
        override func restoreCompletedTransactions() {
            messages.append(.restore)
            
            transactionObservers.first?.paymentQueue(self, updatedTransactions: PaymentQueueSpy.completedTransactions)
            
            if let error = PaymentQueueSpy.completionError {
                transactionObservers.first?.paymentQueue?(self, restoreCompletedTransactionsFailedWithError: error)
            } else {
                transactionObservers.first?.paymentQueueRestoreCompletedTransactionsFinished?(self)
            }
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
