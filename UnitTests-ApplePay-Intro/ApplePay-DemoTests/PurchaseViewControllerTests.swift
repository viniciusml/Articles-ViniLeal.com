//
//  PurchaseViewControllerTests.swift
//  ApplePay-DemoTests
//
//  Created by Vinicius Leal on 24/09/2020.
//  Copyright © 2020 Vinicius Leal. All rights reserved.
//

import ApplePay_Demo
import PassKit
import XCTest

class PurchaseViewControllerTests: XCTestCase {
    func test_delegateDidAuthorizePayment_forwardsMessageToProvider() throws {
        let payment = PKPayment()
        let (sut, provider) = makeSUT()

        sut.paymentAuthorizationViewController(try XCTUnwrap(makeAuthController()), didAuthorizePayment: payment, completion: { _ in })
        
        XCTAssertEqual(provider.payments, [payment])
    }
    
    // MARK - Helpers
    
    private func makeSUT() -> (sut: PurchaseViewController, provider: PaymentProviderSpy) {
        let provider = PaymentProviderSpy()
        let sut = PurchaseViewController(
            paymentProvider: provider,
            paymentAuthorizationHandler: PaymentAuthorizationHandler())
        return (sut, provider)
    }
    
    private func makeAuthController() -> PKPaymentAuthorizationViewController? {
        PKPaymentAuthorizationViewController(paymentRequest: .validRequest)
    }
}
