//
//  StoreObserver.swift
//  InAppPurchase
//
//  Created by Vinicius Moreira Leal on 07/02/2021.
//

import StoreKit

public class PaymentTransactionObserver: NSObject {
    public typealias TransactionResult = Result<[PaymentTransaction], Error>
    
    private let queue: SKPaymentQueue
    private var restoredTransactions = [PaymentTransaction]()
    public var onTransactionsUpdate: ((TransactionResult) -> Void)?
    
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
        completeWith(.transaction(.purchased, transaction.payment.productIdentifier))
        queue.finishTransaction(transaction)
    }
    
    private func failed(_ transaction: SKPaymentTransaction) {
        guard transaction.paymentWasNotCancelled else { return }
        
        completeWith(.transaction(.failed, transaction.payment.productIdentifier))
        queue.finishTransaction(transaction)
    }
    
    private func restored(_ transaction: SKPaymentTransaction) {
        guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }
        
        restoredTransactions.append(.transaction(.restored, productIdentifier))
        queue.finishTransaction(transaction)
    }
    
    private func completeWith(_ transactions: PaymentTransaction...) {
        completeWith(transactions)
    }
    
    private func completeWith(_ transactions: [PaymentTransaction]) {
        onTransactionsUpdate?(.success(transactions))
    }
    
    private func completeWith(_ error: Error) {
        onTransactionsUpdate?(.failure(error))
    }
}

extension PaymentTransactionObserver: SKPaymentTransactionObserver {
    
    public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        if !restoredTransactions.isEmpty {
            completeWith(restoredTransactions)
        }
        restoredTransactions = []
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        onTransactionsUpdate?(.failure(error))
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
