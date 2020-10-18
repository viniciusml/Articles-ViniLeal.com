//
//  PaymentAuthorizationHandlerTests.swift
//  ApplePay-DemoTests
//
//  Created by Vinicius Leal on 15/10/2020.
//  Copyright © 2020 Vinicius Leal. All rights reserved.
//

import ApplePay_Demo
import PassKit
import XCTest

class PaymentAuthorizationHandlerTests: XCTestCase {
    func test_requestAuthorization_failsWhenPaymentNetworkNotSupported() {
        let (sut, _) = makeSUT(request: .validRequest, authorizedNetworks: false)
        
        expect(sut, toCompleteWith: .failure(.networkNotSupported))
    }
    
    func test_requestAuthorization_succeedsWhenPaymentNetworkSupported() {
        let (sut, _) = makeSUT(request: .validRequest, authorizedNetworks: true)
        
        expectSuccessfulCompletion(on: sut)
    }
    
    func test_requestAuthorization_failsWhenControllerInitialisationFails() {
        let (sut, _) = makeSUT(request: .invalidRequest, authorizedNetworks: true)
        
        expect(sut, toCompleteWith: .failure(.unableToInitialize))
    }
    
    // MARK: - Helpers
    
    private func makeSUT(request: PKPaymentRequest,
                         authorizedNetworks: Bool) -> (
                            sut: PaymentAuthorizationHandler,
                            authController: PKPaymentAuthorizationViewController?) {
        let authController = PKPaymentAuthorizationViewController(paymentRequest: request)
        let sut = PaymentAuthorizationHandler(controllerFactory: { request in
            authController
        }, networkAuthorizationHandler: { networks in
            authorizedNetworks
        })
        return (sut, authController)
    }
    
    private func expectSuccessfulCompletion(on sut: PaymentAuthorizationHandler, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toCompleteWith: nil, file: file, line: line)
    }
    
    private func expect(_ sut: PaymentAuthorizationHandler, toCompleteWith expectedCompletion: Result<PKPaymentAuthorizationViewController, PaymentAuthorizationHandler.Error>?, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for request permission")
        
        sut.requestAuthorization { receivedCompletion in
            switch (receivedCompletion, expectedCompletion) {
                case let (.failure(receivedError), .failure(expectedError)):
                    XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                    
                case let (.success(receivedController), nil):
                    XCTAssertNotNil(receivedController, "Request might be incomplete, or payment is not possible", file: file, line: line)
                    
                default:
                    XCTFail("Expected completion \(String(describing: expectedCompletion)) but got \(receivedCompletion) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
}
