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
        let productLoader = ProductLoaderSpy()
        let transactionObserver = PaymentTransactionObserverStub()
        let productResultHandler = ProductResultHandlerStub()
        let transactionHandler = PaymentTransactionResultHandlerStub()
        let sut = PurchaseCoordinator(
            productLoader: productLoader,
            transactionObserver: transactionObserver,
            productResultHandler: productResultHandler,
            transactionHandler: transactionHandler)
        
        let exp = expectation(description: "wait for load")
        var availableProducts: [AvailableProduct]?
        let expectedAvailableProducts = [
            AvailableProduct(id: "product 1", title: "title 1", price: "12"),
            AvailableProduct(id: "product 2", title: "title 2", price: "13")
        ]
        
        sut.loadProducts()
        sut.onLoad = {
            availableProducts = $0
            exp.fulfill()
        }
        // Timely coupled, needs to be stubbed after the call.
        let result = ProductLoaderDelegate.ProductsResult.success(
            [dummyProduct(identifier: "product 1", title: "title 1", priceValue: 12.00),
             dummyProduct(identifier: "product 2", title: "title 2", priceValue: 13.00)])
        productResultHandler.stubbedResult = result
        
        wait(for: [exp], timeout: 0.1)
        XCTAssertEqual(productLoader.fetchProductsCallCount, 1)
        XCTAssertEqual(availableProducts, expectedAvailableProducts)
    }
    
    func test_loadProductsWithFailure_doesNotDeliverAvailableProducts() {
        let productLoader = ProductLoaderSpy()
        let transactionObserver = PaymentTransactionObserverStub()
        let productResultHandler = ProductResultHandlerStub()
        let transactionHandler = PaymentTransactionResultHandlerStub()
        let sut = PurchaseCoordinator(
            productLoader: productLoader,
            transactionObserver: transactionObserver,
            productResultHandler: productResultHandler,
            transactionHandler: transactionHandler)
        
        let exp = expectation(description: "wait for load")
        exp.isInverted = true
        var availableProducts: [AvailableProduct]?
        
        sut.loadProducts()
        sut.onLoad = {
            availableProducts = $0
            exp.fulfill()
        }
        // Timely coupled, needs to be stubbed after the call.
        let result = ProductLoaderDelegate.ProductsResult.failure(anyNSError())
        productResultHandler.stubbedResult = result
        
        wait(for: [exp], timeout: 0.1)
        XCTAssertEqual(productLoader.fetchProductsCallCount, 1)
        XCTAssertNil(availableProducts)
    }
    
    
    // MARK: - Helpers
    
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
    
    private class PaymentTransactionObserverStub: PaymentTransactionObserving {
        static var stubbedResult: PaymentTransactionObserverDelegate.TransactionResult = .success([])
        
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
    
    private class PaymentTransactionResultHandlerStub: PaymentTransactionResultHandling {
        var completion: ((TransactionResult) -> Void)?
        
        func didUpdateTransactions(with result: TransactionResult) {
            
        }
    }
}
