//
//  RemotePaymentProvider.swift
//  ApplePay-Demo
//
//  Created by Vinicius Leal on 15/10/2020.
//  Copyright © 2020 Vinicius Leal. All rights reserved.
//

import PassKit

public class RemotePaymentProvider: PaymentProvider {
    
    // To be removed
    public init() {}
    
    public func processPayment(_ payment: PKPayment, completion: @escaping (Error?) -> Void) {
        // Implement payment validation with provider
    }
}
