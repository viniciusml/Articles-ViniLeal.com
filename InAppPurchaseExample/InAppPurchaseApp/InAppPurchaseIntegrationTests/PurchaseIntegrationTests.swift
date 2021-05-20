//
//  PurchaseIntegrationTests.swift
//  InAppPurchaseTests
//
//  Created by Vinicius Moreira Leal on 18/03/2021.
//

import InAppPurchase
import StoreKitTest
import XCTest

class PurchaseIntegrationTests: XCTestCase {
    
    func test_successfullNonConsumablePurchase() throws {
        try makeSession(withIdentifier: "CakeShop")
        
        let identifiers = expectedIdentifiers(.saltedCaramelCake, .redVelvetCake)
        let (observer, loader, delegate) = makeSUT(identifiers: identifiers)
        
        let fetchedProducts = fetchProducts(with: loader, delegate: delegate)
        try expectPurchased(fetchedProducts.first, with: observer, toHaveIdentifier: identifiers[0], andState: .purchased)
    }
    
    func test_interruptedNonConsumablePurchase() throws {
        let session =  try makeSession(withIdentifier: "CakeShop")
        session.interruptPurchase()
        let identifiers = expectedIdentifiers(.saltedCaramelCake, .redVelvetCake)
        let (observer, loader, delegate) = makeSUT(identifiers: identifiers)
        
        let fetchedProducts = fetchProducts(with: loader, delegate: delegate)
        try expectPurchased(fetchedProducts.last, with: observer, toHaveIdentifier: identifiers[1], andState: .failed)
    }
    
    // MARK: - Helpers
    
    @discardableResult
    private func makeSession(withIdentifier identifier: String) throws -> SKTestSession {
        let session = try SKTestSession(configurationFileNamed: identifier)
        session.resetToDefaultState()
        session.disableDialogs = true
        return session
    }
    
    private func makeSUT(identifiers: [String]) -> (observer: PaymentTransactionObserver, loader: ProductLoader, delegate: ProductLoaderDelegateSpy) {
        let transactionObserver = PaymentTransactionObserver()
        let purchaseLoader = ProductLoader(request: ProductRequestFactory.make(with: identifiers))
        let delegate = ProductLoaderDelegateSpy()
        purchaseLoader.delegate = delegate
        return (transactionObserver, purchaseLoader, delegate)
    }
    
    private func fetchProducts(with loader: ProductLoader, delegate: ProductLoaderDelegateSpy, file: StaticString = #filePath, line: UInt = #line) -> [SKProduct] {
        let exp = expectation(description: "Wait for load completion")
        loader.fetchProducts()
        
        var loadedProducts = [SKProduct]()
        delegate.completion = { result in
            switch result {
            case let .success(fetchedProducts):
                loadedProducts.append(contentsOf: fetchedProducts)
            case let .failure(error):
                XCTFail("Expected products, got \(error) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        
        return loadedProducts
    }
    
    private func expectPurchased(_ product: SKProduct?, with observer: PaymentTransactionObserver, toHaveIdentifier identifier: String, andState state: PaymentTransaction.State, file: StaticString = #filePath, line: UInt = #line) throws {
        let exp = expectation(description: "Wait for purchase completion")
        let product = try XCTUnwrap(product, "Could not unwrap product", file: file, line: line)
        
        observer.buy(product)
        observer.onTransactionsUpdate = { result in
            switch result {
            case let .success(transactions):
                let transaction = transactions.first!
                XCTAssertEqual(transaction.identifier, identifier)
                XCTAssertEqual(transaction.state, state)
            case let .failure(error):
                XCTFail("Expected success, got \(error) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
    }
    
    private func expectedIdentifiers(_ identifiers: Bakery...) -> [String] {
        Array(identifiers.map { $0.rawValue })
    }
    
    private enum Bakery: String {
        // Non-Consumable
        case carrotCake = "com.inAppPurchaseExample.carrotCake"
        case chocolateCake = "com.inAppPurchaseExample.chocolateCake"
        
        // Consumable
        case saltedCaramelCake = "com.inAppPurchaseExample.saltedCaramelCake"
        case redVelvetCake = "com.inAppPurchaseExample.redVelvetCake"
    }
    
    private class ProductLoaderDelegateSpy: ProductLoaderDelegate {
        var completion: ((ProductsResult) -> Void)?
        
        func didFetchProducts(with result: ProductsResult) {
            completion?(result)
        }
    }
}

private extension SKTestSession {
    func interruptPurchase() {
        interruptedPurchasesEnabled = true
        clearTransactions()
    }
}
