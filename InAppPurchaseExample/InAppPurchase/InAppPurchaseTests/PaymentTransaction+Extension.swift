//
//  PaymentTransaction+Extension.swift
//  InAppPurchaseTests
//
//  Created by Vinicius Moreira Leal on 19/03/2021.
//

@testable import InAppPurchase

extension PaymentTransaction {
    static func make(_ state: PaymentTransaction.State, with identifier: String) -> PaymentTransaction {
        PaymentTransaction(state: state, identifier: identifier)
    }
}
