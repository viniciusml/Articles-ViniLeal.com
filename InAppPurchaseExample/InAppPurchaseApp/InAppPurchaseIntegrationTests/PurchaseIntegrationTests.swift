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
        let (observer, loader) = makeSUT(identifiers: identifiers)
        
        let fetchedProducts = fetchProducts(with: loader)
        try expectPurchased(fetchedProducts.first, with: observer, toHaveIdentifier: identifiers[0], andState: .purchased)
    }
    
    func test_interruptedNonConsumablePurchase() throws {
        let session =  try makeSession(withIdentifier: "CakeShop")
        session.interruptPurchase()
        let identifiers = expectedIdentifiers(.saltedCaramelCake, .redVelvetCake)
        let (observer, loader) = makeSUT(identifiers: identifiers)
        
        let fetchedProducts = fetchProducts(with: loader)
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
    
    private func makeSUT(identifiers: [String]) -> (observer: PaymentTransactionObserver, loader: ProductLoader) {
        let transactionObserver = PaymentTransactionObserver()
        let purchaseLoader = ProductLoader(request: ProductRequestFactory.make(with: identifiers))
        return (transactionObserver, purchaseLoader)
    }
    
    private func fetchProducts(with loader: ProductLoader, file: StaticString = #filePath, line: UInt = #line) -> [SKProduct] {
        let exp = expectation(description: "Wait for load completion")
        
        var loadedProducts = [SKProduct]()
        loader.fetchProducts()
        loader.completion = { result in
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
            if let transaction = try? result.get().first {
                XCTAssertEqual(transaction.identifier, identifier)
                XCTAssertEqual(transaction.state, state)
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
        case carrotCake = "com.inAppPurchase.carrot.cake"
        case chocolateCake = "com.inAppPurchase.chocolate.cake"
        
        // Consumable
        case saltedCaramelCake = "com.inAppPurchase.salted.caramel.cake"
        case redVelvetCake = "com.inAppPurchase.red.velvet.cake"
    }
}

private extension SKTestSession {
    func interruptPurchase() {
        interruptedPurchasesEnabled = true
        clearTransactions()
    }
}
