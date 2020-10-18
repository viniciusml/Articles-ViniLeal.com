//
//  PassKit+TestHelpers.swift
//  ApplePay-DemoTests
//
//  Created by Vinicius Leal on 16/10/2020.
//  Copyright © 2020 Vinicius Leal. All rights reserved.
//

import PassKit

extension PKPaymentRequest {
    static var validRequest: PKPaymentRequest {
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
    
    static var invalidRequest: PKPaymentRequest {
        PKPaymentRequest()
    }
}
