//
//  StoreObserver.swift
//  InAppPurchase
//
//  Created by Vinicius Moreira Leal on 07/02/2021.
//

import StoreKit

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
        completion?(.transaction(.purchased, transaction.payment.productIdentifier))
        queue.finishTransaction(transaction)
    }
    
    private func failed(_ transaction: SKPaymentTransaction) {
        guard transaction.paymentWasNotCancelled else { return }
        
        completion?(.transaction(.failed, transaction.payment.productIdentifier))
        queue.finishTransaction(transaction)
    }
    
    private func restored(_ transaction: SKPaymentTransaction) {
        
        guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }
        
        completion?(.transaction(.restored, productIdentifier))
        queue.finishTransaction(transaction)
    }
}

extension PaymentTransactionObserver: SKPaymentTransactionObserver {
    
    public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        transactions.handle(purchased, failed, restored)
    }
}

private extension SKPaymentTransaction {
    var paymentWasNotCancelled: Bool {
        guard let transactionError = error as NSError? else { return false }
        return transactionError.code != SKError.paymentCancelled.rawValue
    }
}
