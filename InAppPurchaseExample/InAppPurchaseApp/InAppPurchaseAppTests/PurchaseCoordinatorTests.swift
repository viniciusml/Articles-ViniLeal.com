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
    
    var sut: PurchaseCoordinator!
    private var productLoader: ProductLoaderSpy!
    private var productResultHandler: ProductResultHandlerStub!
    private var transactionObserver: PaymentTransactionObserverSpy!
    private var transactionHandler: PaymentTransactionResultHandlerStub!
    
    override func setUp() {
        super.setUp()
        
        productLoader = ProductLoaderSpy()
        transactionObserver = PaymentTransactionObserverSpy()
        productResultHandler = ProductResultHandlerStub()
        transactionHandler = PaymentTransactionResultHandlerStub()
        sut = PurchaseCoordinator(
            productLoader: productLoader,
            transactionObserver: transactionObserver,
            productResultHandler: productResultHandler,
            transactionHandler: transactionHandler)
    }
    
    func test_loadProductsWithSuccess_deliversAvailableProducts() {
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
        expect(sut, toDeliverAvailableProducts: { availableProducts in
            XCTAssertEqual(productLoader.fetchProductsCallCount, 1)
            XCTAssertNil(availableProducts)
        }, when: {
            productResultHandler.stubbedResult = .failure(anyNSError())
        }, expectationIsInverted: true)
    }
    
    func test_restoreWithSuccess_deliversPurchasedProducts() {
        let expectedPurchasedProducts = [
            PurchasedProduct(id: "id 1", title: "title 1"),
            PurchasedProduct(id: "id 2", title: "title 2")
        ]
        setup(sut, withAvailableProducts: [
            dummyProduct(identifier: "id 1", title: "title 1", priceValue: 12.00),
            dummyProduct(identifier: "id 2", title: "title 2", priceValue: 13.00),
            dummyProduct(identifier: "id 3", title: "title 3", priceValue: 15.00)
        ])
        
        expect(sut, toDeliverPurchasedProducts: { purchasedProducts in
            XCTAssertEqual(transactionObserver.calls, [.restore])
            assertEqualRegardlessOfOrder(purchasedProducts, expectedPurchasedProducts)
        }, when: {
            transactionHandler.stubbedResult = .success(
                [
                    .transaction(.restored, "id 1"),
                    .transaction(.restored, "id 2")
                ]
            )
        })
    }
    
    func test_restoreWithSuccess_andNoAvailableProduct_deliversZeroPurchasedProducts() {
        setup(sut, withAvailableProducts: [])
        
        expect(sut, toDeliverPurchasedProducts: { purchasedProducts in
            XCTAssertEqual(transactionObserver.calls, [.restore])
            XCTAssertEqual(purchasedProducts, [])
        }, when: {
            transactionHandler.stubbedResult = .success(
                [
                    .transaction(.restored, "id 1"),
                    .transaction(.restored, "id 2")
                ]
            )
        })
    }
    
    func test_restoreWithFailure_doesNotDeliverPurchasedProducts() {
        setup(sut, withAvailableProducts: [
            dummyProduct(identifier: "id 1", title: "title 1", priceValue: 12.00),
            dummyProduct(identifier: "id 2", title: "title 2", priceValue: 13.00)
        ])
        
        expect(sut, toDeliverPurchasedProducts: { purchasedProducts in
            XCTAssertEqual(transactionObserver.calls, [.restore])
            XCTAssertNil(purchasedProducts)
        }, when: {
            transactionHandler.stubbedResult = .failure(anyNSError())
        }, expectationIsInverted: true)
    }
    
    // TODO: - Test array logic
    
    // MARK: - Helpers
    
    private func setup(_ sut: PurchaseCoordinator, withAvailableProducts availableProducts: [SKProduct]) {
        sut.loadProducts()
        productResultHandler.stubbedResult = .success(availableProducts)
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
    
    private func assertEqualRegardlessOfOrder(_ array1: [PurchasedProduct]?, _ array2: [PurchasedProduct]?, file: StaticString = #filePath, line: UInt = #line) {
        let failureMessage = "\(String(describing: array1)) not equal to \(String(describing: array2))"
        guard let array1 = array1, let array2 = array2 else {
            return XCTFail(failureMessage, file: file, line: line)
        }
        
        XCTAssertTrue(Set(array1) == Set(array2), failureMessage, file: file, line: line)
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

private extension PurchasedProduct {
    
    static func make(_ id: String) -> PurchasedProduct {
        PurchasedProduct(id: id, title: "title \(id)")
    }
}
