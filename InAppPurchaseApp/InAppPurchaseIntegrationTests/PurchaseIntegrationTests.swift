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
    private var session: SKTestSession!
    
    override func setUpWithError() throws {
        try super.tearDownWithError()
        
        session = try SKTestSession(configurationFileNamed: "CakeShop")
        session.resetToDefaultState()
        session.disableDialogs = true
    }
    
    override func tearDown() {
        session.resetToDefaultState()
        session.disableDialogs = true
        
        super.tearDown()
    }
    
    func testSuccessfullNonConsumablePurchase() throws {
        let identifiers = expectedIdentifiers(.carrotCake, .chocolateCake)
        let loadingExpectation = expectation(description: "Wait for loading available products")
        let purchaseExpectation = expectation(description: "Wait for products purchase")

        let purchaseObserver = PaymentTransactionObserver()
        let purchaseLoader = ProductLoader(request: ProductRequestFactory.make(with: identifiers))

        purchaseLoader.fetchProducts()
        purchaseLoader.completion = { result in
            switch result {
            case let .success(fetchedProducts):
                
                if let product = fetchedProducts.first {
                    purchaseObserver.buy(product)
                    purchaseObserver.completion = { transaction in
                        
                        XCTAssertEqual(transaction.identifier, identifiers[0])
                        XCTAssertEqual(transaction.state, .purchased)
                        purchaseExpectation.fulfill()
                    }
                }
            case let .failure(error):
                XCTFail("Expected products, got \(error) instead")
            }
            
            loadingExpectation.fulfill()
        }
        
        wait(for: [loadingExpectation, purchaseExpectation], timeout: 1.5)
    }
    
    func testInterruptedNonConsumablePurchase() throws {
        session.interruptedPurchasesEnabled = true
        session.clearTransactions()

        let identifiers = expectedIdentifiers(.carrotCake, .chocolateCake)
        let loadingExpectation = expectation(description: "Wait for loading available products")
        let purchaseExpectation = expectation(description: "Wait for products purchase")

        let purchaseObserver = PaymentTransactionObserver()
        let purchaseLoader = ProductLoader(request: ProductRequestFactory.make(with: identifiers))

        purchaseLoader.fetchProducts()
        purchaseLoader.completion = { result in
            switch result {
            case let .success(fetchedProducts):

                if let product = fetchedProducts.last {
                    purchaseObserver.buy(product)
                    purchaseObserver.completion = { transaction in

                        XCTAssertEqual(transaction.identifier, identifiers[1])
                        XCTAssertEqual(transaction.state, .failed)
                        purchaseExpectation.fulfill()
                    }
                }
            case let .failure(error):
                XCTFail("Expected products, got \(error) instead")
            }

            loadingExpectation.fulfill()
        }

        wait(for: [loadingExpectation, purchaseExpectation], timeout: 1.5)
    }
    
    // MARK: - Helpers
    
    private func expectedIdentifiers(_ identifiers: Bakery...) -> [String] {
        Array(identifiers.map { $0.rawValue })
    }
    
    private enum Bakery: String {
        case carrotCake = "com.inAppPurchase.carrot.cake"
        case chocolateCake = "com.inAppPurchase.chocolate.cake"
    }
}

