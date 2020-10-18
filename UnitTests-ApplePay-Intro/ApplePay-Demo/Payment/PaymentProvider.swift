//
//  PaymentProvider.swift
//  ApplePay-Demo
//
//  Created by Vinicius Leal on 15/10/2020.
//  Copyright © 2020 Vinicius Leal. All rights reserved.
//

import PassKit

public protocol PaymentProvider {
    func processPayment(_ payment: PKPayment, completion: @escaping (Error?) -> Void)
}
