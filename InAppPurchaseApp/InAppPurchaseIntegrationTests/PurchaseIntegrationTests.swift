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
    
    func testSuccessfullPurchase() throws {
        let session = try SKTestSession(configurationFileNamed: "CakeShop")
        session.resetToDefaultState()
        session.disableDialogs = true

//        session.interruptedPurchasesEnabled = true
//        session.clearTransactions()

        let identifiers = expectedIdentifiers(.carrotCake, .chocolateCake)
        let expectation = XCTestExpectation(description: "Wait for purchase")

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
                    }
                }
                
                if let product = fetchedProducts.last {
                    purchaseObserver.buy(product)
                    purchaseObserver.completion = { transaction in
                        
                        XCTAssertEqual(transaction.identifier, identifiers[1])
                    }
                }
            case let .failure(error):
                XCTFail("Expected products, got \(error) instead")
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.5)
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

