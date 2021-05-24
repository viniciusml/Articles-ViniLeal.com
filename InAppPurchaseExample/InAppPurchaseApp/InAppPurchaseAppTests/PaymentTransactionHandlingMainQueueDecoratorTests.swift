//
//  PaymentTransactionHandlingMainQueueDecoratorTests.swift
//  InAppPurchaseAppTests
//
//  Created by Vinicius Moreira Leal on 24/05/2021.
//

@testable import InAppPurchaseApp
import InAppPurchase
import StoreKit
import XCTest

class PaymentTransactionHandlingMainQueueDecoratorTests: XCTestCase {
    typealias Result = Swift.Result<[PaymentTransaction], Error>
    
    func test_didUpdateTransactionsFromRestoreWithFailure_deliversResultInMainThread() {
        let expectedResult = Result.failure(anyNSError())
        PaymentTransactionObserverStub.stubbedResult = expectedResult
        let (transactionObserver, sut) = makeSUT()
        
        transactionObserver.restore()
        
        sut.completion = { receivedResult in
            XCTAssert(Thread.isMainThread)
            assertEqual(receivedResult.failure, expectedResult.failure)
        }
    }
    
    func test_didUpdateTransactionsFromRestoreWithSuccess_deliversResultInMainThread() {
        let expectedResult = Result.success([anyTransaction()])
        PaymentTransactionObserverStub.stubbedResult = expectedResult
        let (transactionObserver, sut) = makeSUT()
        
        transactionObserver.restore()
        
        sut.completion = { receivedResult in
            XCTAssert(Thread.isMainThread)
            XCTAssertEqual(receivedResult.success, expectedResult.success)
        }
    }
    
    func test_didUpdateTransactionsFromPurchaseWithFailure_deliversResultInMainThread() {
        let expectedResult = Result.failure(anyNSError())
        PaymentTransactionObserverStub.stubbedResult = expectedResult
        let (transactionObserver, sut) = makeSUT()
        
        transactionObserver.buy(anyProduct())
        
        sut.completion = { receivedResult in
            XCTAssert(Thread.isMainThread)
            assertEqual(receivedResult.failure, expectedResult.failure)
        }
    }
    
    func test_didUpdateTransactionsFromPurchaseWithSuccess_deliversResultInMainThread() {
        let expectedResult = Result.success([anyTransaction()])
        PaymentTransactionObserverStub.stubbedResult = expectedResult
        let (transactionObserver, sut) = makeSUT()
        
        transactionObserver.buy(anyProduct())
        
        sut.completion = { receivedResult in
            XCTAssert(Thread.isMainThread)
            XCTAssertEqual(receivedResult.success, expectedResult.success)
        }
    }
    
    // MARK: - Helpers
    
    private class PaymentTransactionObserverStub: PaymentTransactionObserving {
        static var stubbedResult: Result = .success([])
        
        var delegate: PaymentTransactionObserverDelegate?
        
        func buy(_ product: SKProduct) {
            complete()
        }
        
        func restore() {
            complete()
        }
        
        private func complete() {
            DispatchQueue.global(qos: .background).async {
                self.delegate?.didUpdateTransactions(with: PaymentTransactionObserverStub.stubbedResult)
            }
        }
    }
    
    private func makeSUT() -> (paymentTransactionObserver: PaymentTransactionObserving, sut: PaymentTransactionResultHandling) {
        let observer = PaymentTransactionObserverStub()
        let sut = MainQueueDecorator(PaymentTransactionHandler())
        observer.delegate = sut
        return (observer, sut)
    }
    
    private func anyTransaction() -> PaymentTransaction {
        PaymentTransaction.transaction(.purchased, "identifier")
    }
}
