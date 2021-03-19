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
    
//    func testInterruptedPurchase() throws {
//        let session = try SKTestSession(configurationFileNamed: "RecipesAndCoins")
//        session.resetToDefaultState()
//        session.disableDialogs = true
//
//        session.interruptedPurchasesEnabled = true
//        session.clearTransactions()
//
//        let identifier = Bakery.carrotCake
//        let expectation = XCTestExpectation(description: "Wait for purchase")
//
//        let purchaseObserver = PaymentTransactionObserver()
//        let purchaseLoader = ProductLoader(request: ProductRequestFactory.make(with: [identifier]))
//
//        purchaseLoader.fetchProducts()
//        purchaseLoader.completion = { result in
//            if let product = try? result.get().first {
//
//                purchaseObserver.buy(product)
//                purchaseObserver.completion = { result in
//
//                }
//            }
//        }
//
//
//        GreenBarContent.store.requestProductsAndBuy(
//            productIdentifier: identifier
//        ) { _ in
//            let contentAvailable = GreenBarContent.store.receiptContains(identifier)
//            let contentSaved = GreenBarContent.store.isProductPurchased(identifier)
//
//            XCTAssertFalse(
//                contentAvailable,
//                "Expected \(identifier) is not present in receipt")
//            XCTAssertFalse(
//                contentSaved,
//                "Expected \(identifier) is not stored in PurchasedProducts")
//
//            expectation.fulfill()
//        }
//
//        wait(for: [expectation], timeout: 60.0)
//    }
}

