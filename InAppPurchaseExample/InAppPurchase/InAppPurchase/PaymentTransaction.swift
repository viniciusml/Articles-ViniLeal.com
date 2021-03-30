//
//  PaymentTransaction.swift
//  InAppPurchase
//
//  Created by Vinicius Moreira Leal on 19/03/2021.
//

import Foundation

public struct PaymentTransaction: Equatable {
    public enum State: Equatable {
        case purchased
        case restored
        case failed
    }
    
    public let state: State
    public let identifier: String
    
    static func transaction(_ state: State, _ identifier: String) -> PaymentTransaction {
        PaymentTransaction(state: state, identifier: identifier)
    }
}
