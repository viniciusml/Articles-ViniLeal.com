//
//  PurchaseIntegrationTests.swift
//  InAppPurchaseTests
//
//  Created by Vinicius Moreira Leal on 18/03/2021.
//

import InAppPurchase
import StoreKitTest
import XCTest

private enum Bakery {
    public static let carrotCake = "com.inAppPurchase.carrot.cake"
    public static let chocolateCake = "com.inAppPurchase.chocolate.cake"
}

class PurchaseIntegrationTests: XCTestCase {
    
    func testPurchase() throws {
        let session = try SKTestSession(configurationFileNamed: "TestSession")
        session.resetToDefaultState()
        session.disableDialogs = true

        session.interruptedPurchasesEnabled = true
        session.clearTransactions()

        let identifier = Bakery.carrotCake
        let expectation = XCTestExpectation(description: "Wait for purchase")

        let purchaseObserver = PaymentTransactionObserver()
        let purchaseLoader = ProductLoader(request: ProductRequestFactory.make(with: [identifier]))

        purchaseLoader.fetchProducts()
        purchaseLoader.completion = { result in
            if let product = try? result.get().first {

                purchaseObserver.buy(product)
                purchaseObserver.completion = { transaction in
                    
                    XCTAssertEqual(transaction.identifier, identifier)
                    expectation.fulfill()
                }
            }
        }
        
        wait(for: [expectation], timeout: 0.5)
    }
}

