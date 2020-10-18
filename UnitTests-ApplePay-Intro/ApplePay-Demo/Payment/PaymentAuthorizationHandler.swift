//
//  PaymentAuthorizationHandler.swift
//  ApplePay-Demo
//
//  Created by Vinicius Leal on 15/10/2020.
//  Copyright © 2020 Vinicius Leal. All rights reserved.
//

import PassKit

public class PaymentAuthorizationHandler {
    public typealias ApplePayControllerFactory = (PKPaymentRequest) -> PKPaymentAuthorizationViewController?
    public typealias ApplePayCompletionHandler = (Result<PKPaymentAuthorizationViewController, Error>) -> Void
    public typealias NetworkAuthorizationHandler = ([PKPaymentNetwork]) -> Bool
    
    public enum Error: Swift.Error {
        case networkNotSupported
        case unableToInitialize
    }
    
    private let controllerFactory: ApplePayControllerFactory
    private let networkAuthorizationHandler: NetworkAuthorizationHandler
    
    public init(
        controllerFactory: @escaping ApplePayControllerFactory = PKPaymentAuthorizationViewController.init,
        networkAuthorizationHandler: @escaping NetworkAuthorizationHandler = PKPaymentAuthorizationViewController.canMakePayments
    ) {
        self.controllerFactory = controllerFactory
        self.networkAuthorizationHandler = networkAuthorizationHandler
    }
    
    private func makeRequest() -> PKPaymentRequest {
        let paymentNetworks: [PKPaymentNetwork] = [.amex, .discover, .masterCard, .visa]
        let paymentItem = PKPaymentSummaryItem(label: "Item name", amount: NSDecimalNumber(value: 22.0))
        let request = PKPaymentRequest()
        request.currencyCode = "USD"
        request.countryCode = "US"
        request.merchantIdentifier = "merchant.com"
        request.merchantCapabilities = PKMerchantCapability.capability3DS
        request.supportedNetworks = paymentNetworks
        request.paymentSummaryItems = [paymentItem]
        return request
    }
    
    public func requestAuthorization(completion: ApplePayCompletionHandler) {
        let request = makeRequest()
        
        guard networkAuthorizationHandler(request.supportedNetworks) else {
            completion(.failure(.networkNotSupported))
            return
        }
        guard let paymentVC = controllerFactory(request) else {
            completion(.failure(.unableToInitialize))
            return
        }
        
        completion(.success(paymentVC))
    }
}
