//
//  StoreObserver.swift
//  InAppPurchase
//
//  Created by Vinicius Moreira Leal on 07/02/2021.
//

import StoreKit

public class StoreObserver: NSObject {
    
    let queue: SKPaymentQueue
    
    public init(queue: SKPaymentQueue = .default()) {
        self.queue = queue
    }
    
    public func buy(_ product: SKProduct) {
        let payment = SKMutablePayment(product: product)
        queue.add(payment)
    }
    
    public func restore() {
        queue.restoreCompletedTransactions()
    }
    
    private func handlePurchased(_ transaction: SKPaymentTransaction) {
        queue.finishTransaction(transaction)
    }
    
    private func handleFailed(_ transaction: SKPaymentTransaction) {
        queue.finishTransaction(transaction)
    }
    
    private func handleRestored(_ transaction: SKPaymentTransaction) {
        queue.finishTransaction(transaction)
    }
}

extension StoreObserver: SKPaymentTransactionObserver {
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        transactions.forEach { transaction in
            
            switch transaction.transactionState {
            case .purchasing, .deferred:
                break
            case .purchased:
                handlePurchased(transaction)
            case .failed:
                handleFailed(transaction)
            case .restored:
                handleRestored(transaction)
            @unknown default: fatalError()
            }
        }
    }
}
