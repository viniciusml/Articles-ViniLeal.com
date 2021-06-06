//
//  PurchaseCoordinatorTests.swift
//  InAppPurchaseAppTests
//
//  Created by Vinicius Moreira Leal on 26/05/2021.
//

import InAppPurchase
@testable import InAppPurchaseApp
import StoreKit // Remove this
import XCTest

class PurchaseCoordinatorTests: XCTestCase {
    
    func test_loadProductsWithSuccess_deliversAvailableProducts() {
        let (sut, productLoader, productResultHandler) = makeSUTWithLoader()
        let expectedAvailableProducts = [
            AvailableProduct(id: "product 1", title: "title 1", price: "12"),
            AvailableProduct(id: "product 2", title: "title 2", price: "13")
        ]
        
        expect(sut, toDeliverAvailableProducts: { availableProducts in
            XCTAssertEqual(productLoader.fetchProductsCallCount, 1)
            XCTAssertEqual(availableProducts, expectedAvailableProducts)
        }, when: {
            productResultHandler.stubbedResult = .success(
                [
                    dummyProduct(identifier: "product 1", title: "title 1", priceValue: 12.00),
                    dummyProduct(identifier: "product 2", title: "title 2", priceValue: 13.00)
                ]
            )
        })
    }
    
    func test_loadProductsWithFailure_doesNotDeliverAvailableProducts() {
        let (sut, productLoader, productResultHandler) = makeSUTWithLoader()
        
        expect(sut, toDeliverAvailableProducts: { availableProducts in
            XCTAssertEqual(productLoader.fetchProductsCallCount, 1)
            XCTAssertNil(availableProducts)
        }, when: {
            productResultHandler.stubbedResult = .failure(anyNSError())
        }, expectationIsInverted: true)
    }
    
    // TODO: - Test array logic
    
    // MARK: - Helpers
    
    private func makeSUTWithLoader() -> (
        sut: PurchaseCoordinator,
        loader: ProductLoaderSpy,
        resultHandler: ProductResultHandlerStub
    ) {
        let tuple = SUT()
        
        return (tuple.sut, tuple.loader, tuple.resultHandler)
    }
    
    private func makeSUTWithObserver() -> (
        sut: PurchaseCoordinator,
        observer: PaymentTransactionObserverSpy,
        transactionHandler: PaymentTransactionResultHandlerStub
    ) {
        let tuple = SUT()
        
        return (tuple.sut, tuple.observer, tuple.transactionHandler)
    }
    
    private func SUT() -> (
        sut: PurchaseCoordinator,
        loader: ProductLoaderSpy,
        resultHandler: ProductResultHandlerStub,
        observer: PaymentTransactionObserverSpy,
        transactionHandler: PaymentTransactionResultHandlerStub
    ) {
        let productLoader = ProductLoaderSpy()
        let transactionObserver = PaymentTransactionObserverSpy()
        let productResultHandler = ProductResultHandlerStub()
        let transactionHandler = PaymentTransactionResultHandlerStub()
        let sut = PurchaseCoordinator(
            productLoader: productLoader,
            transactionObserver: transactionObserver,
            productResultHandler: productResultHandler,
            transactionHandler: transactionHandler)
        
        return (sut, productLoader, productResultHandler, transactionObserver, transactionHandler)
    }
    
    private func expect(_ sut: PurchaseCoordinator, toDeliverAvailableProducts assertions: ([AvailableProduct]?) -> Void, when action: () -> Void, expectationIsInverted: Bool = false) {
        let exp = expectation(description: "wait for load")
        exp.isInverted = expectationIsInverted
        
        var availableProducts: [AvailableProduct]?
        
        sut.loadProducts()
        sut.onLoad = {
            availableProducts = $0
            exp.fulfill()
        }
        // Timely coupled, needs to be stubbed after the call.
        action()
        
        wait(for: [exp], timeout: 0.1)
        assertions(availableProducts)
    }
    
    private func expect(_ sut: PurchaseCoordinator, toDeliverPurchasedProducts assertions: ([PurchasedProduct]?) -> Void, when action: () -> Void, expectationIsInverted: Bool = false) {
        let exp = expectation(description: "wait for restore")
        exp.isInverted = expectationIsInverted
        
        var purchasedProducts: [PurchasedProduct]?
        
        sut.restorePurchasedProducts()
        sut.onRestore = {
            purchasedProducts = $0
            exp.fulfill()
        }
        // Timely coupled, needs to be stubbed after the call.
        action()
        
        wait(for: [exp], timeout: 0.1)
        assertions(purchasedProducts)
    }
    
    private func dummyProduct(identifier: String, title: String, priceValue: NSDecimalNumber) -> DummySKProduct {
        DummySKProduct(identifier: identifier, title: title, priceValue: priceValue)
    }
    
    private class DummySKProduct: SKProduct {
        private let identifier: String
        private let title: String
        private let priceValue: NSDecimalNumber
        
        init(identifier: String, title: String, priceValue: NSDecimalNumber) {
            self.identifier = identifier
            self.title = title
            self.priceValue = priceValue
        }
        
        override var productIdentifier: String {
            identifier
        }
        
        override var localizedTitle: String {
            title
        }
        
        override var price: NSDecimalNumber {
            priceValue
        }
    }
    
    private class ProductLoaderSpy: ProductLoading {
        
        var delegate: ProductLoaderDelegate?
        private(set) var fetchProductsCallCount = 0
        
        func fetchProducts() {
            fetchProductsCallCount += 1
        }
    }
    
    private class ProductResultHandlerStub: ProductResultHandling {
        
        var stubbedResult: ProductsResult? {
            willSet {
                if let result = newValue {
                    completion?(result)
                }
            }
        }
        var completion: ((ProductsResult) -> Void)?
        
        func didFetchProducts(with result: ProductsResult) {
            completion?(result)
        }
    }
    
    private class PaymentTransactionObserverSpy: PaymentTransactionObserving {

        enum Message {
            case buy
            case restore
        }
        
        var delegate: PaymentTransactionObserverDelegate?
        
        private(set) var calls: [Message] = []
        
        func buy(_ product: SKProduct) {
            calls.append(.buy)
        }
        
        func restore() {
            calls.append(.restore)
        }
    }
    
    private class PaymentTransactionResultHandlerStub: PaymentTransactionResultHandling {
        
        var stubbedResult: TransactionResult? {
            willSet {
                if let result = newValue {
                    completion?(result)
                }
            }
        }
        var completion: ((TransactionResult) -> Void)?
        
        func didUpdateTransactions(with result: TransactionResult) {
            completion?(result)
        }
    }
}
