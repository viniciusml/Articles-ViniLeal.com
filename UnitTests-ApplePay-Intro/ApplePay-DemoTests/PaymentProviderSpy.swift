//
//  PaymentProviderSpy.swift
//  ApplePay-DemoTests
//
//  Created by Vinicius Leal on 16/10/2020.
//  Copyright © 2020 Vinicius Leal. All rights reserved.
//

import ApplePay_Demo
import PassKit

class PaymentProviderSpy: PaymentProvider {
    var payments = [PKPayment]()
    
    func processPayment(_ payment: PKPayment, completion: @escaping (Error?) -> Void) {
        payments.append(payment)
    }
}
