//
//  StoreObserver.swift
//  InAppPurchase
//
//  Created by Vinicius Moreira Leal on 07/02/2021.
//

import StoreKit

public struct PaymentTransaction {
    enum State {
        case purchased
        case restored
        case failed(Error)
    }
    
    let state: State
    let identifier: String
}

// TODO: Add completion for this.
public class PaymentTransactionObserver: NSObject {
    
    private let queue: SKPaymentQueue
    public var completion: ((PaymentTransaction) -> Void)?
    
    public init(queue: SKPaymentQueue = .default()) {
        self.queue = queue
        super.init()
        
        queue.add(self)
    }
    
    public func buy(_ product: SKProduct) {
        let payment = SKMutablePayment(product: product)
        queue.add(payment)
    }
    
    public func restore() {
        queue.restoreCompletedTransactions()
    }
    
    private func purchased(_ transaction: SKPaymentTransaction) {
        queue.finishTransaction(transaction)
    }
    
    private func failed(_ transaction: SKPaymentTransaction) {
        queue.finishTransaction(transaction)
    }
    
    private func restored(_ transaction: SKPaymentTransaction) {
        queue.finishTransaction(transaction)
    }
}

extension PaymentTransactionObserver: SKPaymentTransactionObserver {
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        transactions.handle(purchased, failed, restored)
    }
}
