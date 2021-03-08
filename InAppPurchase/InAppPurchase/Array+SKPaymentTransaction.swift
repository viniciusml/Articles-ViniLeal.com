//
//  Array+SKPaymentTransaction.swift
//  InAppPurchase
//
//  Created by Vinicius Moreira Leal on 08/03/2021.
//

import StoreKit

extension Array where Element == SKPaymentTransaction {
    func handle(_ purchased: (Element) -> Void,
                _ failed: (Element) -> Void,
                _ restored: (Element) -> Void) {
        
        forEach { transaction in
            switch transaction.transactionState {
            case .purchasing, .deferred: break
            case .purchased: purchased(transaction)
            case .failed: failed(transaction)
            case .restored: restored(transaction)
            @unknown default: fatalError()
            }
        }
    }
}
