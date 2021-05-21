//
//  MainQueueDecorator+PaymentTransactionHandling.swift
//  InAppPurchaseApp
//
//  Created by Vinicius Moreira Leal on 21/05/2021.
//

import Foundation
import InAppPurchase

protocol PaymentTransactionHandling: PaymentTransactionObserverDelegate {
    var completion: ((TransactionResult) -> Void)? { get set }
}

typealias PaymentTransactionResultHandling = PaymentTransactionObserverDelegate & PaymentTransactionHandling

class PaymentTransactionHandler: PaymentTransactionResultHandling {
    
    var completion: ((TransactionResult) -> Void)?
    
    func didUpdateTransactions(with result: TransactionResult) {
        completion?(result)
    }
}

extension MainQueueDecorator: PaymentTransactionResultHandling where T: PaymentTransactionResultHandling {
    
    var completion: ((TransactionResult) -> Void)? {
        get {
            decoratee.completion
        }
        set {
            decoratee.completion = newValue
        }
    }
    
    func didUpdateTransactions(with result: TransactionResult) {
        DispatchQueue.main.async {
            self.decoratee.didUpdateTransactions(with: result)
        }
    }
}
