//
//  PurchaseCoordinator.swift
//  InAppPurchaseApp
//
//  Created by Vinicius Moreira Leal on 24/05/2021.
//

import InAppPurchase
import StoreKit

class PurchaseCoordinator {
    private var productLoader: ProductLoading
    private var transactionObserver: PaymentTransactionObserving
    private let productResultHandler: ProductResultHandling
    private let transactionHandler: PaymentTransactionResultHandling
    
    private var availableProducts = [AvailableProduct]()
    
    var onLoad: (([AvailableProduct]) -> Void)?
    var onRestore: (([PurchasedProduct]) -> Void)?
    
    init(productLoader: ProductLoading,
         transactionObserver: PaymentTransactionObserving,
         productResultHandler: ProductResultHandling,
         transactionHandler: PaymentTransactionResultHandling) {
        self.productLoader = productLoader
        self.transactionObserver = transactionObserver
        self.productResultHandler = productResultHandler
        self.transactionHandler = transactionHandler
        
        self.productLoader.delegate = productResultHandler
        self.transactionObserver.delegate = transactionHandler
    }
    
    func loadProducts() {
        productLoader.fetchProducts()
        productResultHandler.completion = { [weak self] result in
            if let products = try? result.get() {
                let availableProducts = products.map { AvailableProduct(id: $0.productIdentifier, title: $0.localizedTitle, price: $0.price.stringValue) }
                self?.availableProducts = availableProducts
                self?.onLoad?(availableProducts)
            }
        }
    }
    
    func restorePurchasedProducts() {
        transactionObserver.restore()
        transactionHandler.completion = { [weak self] result in
            guard let self = self else { return }
            
            if let transactions = try? result.get() {
                
                let restoredTransactions = transactions.map { $0.identifier }
                let availableProducts = self.availableProducts.map { $0.id }
                
                let restoredTransactionsSet = Set(restoredTransactions)
                let availableProductsSet = Set(availableProducts)
                
                let intersectionsIds = Array(restoredTransactionsSet.intersection(availableProductsSet))

                var restoredProducts = [PurchasedProduct]()
                
                intersectionsIds.forEach { id in
                    if let product = self.availableProducts.filter({ $0.id == id }).first {
                        restoredProducts.append(PurchasedProduct(id: product.id, title: product.title))
                    }
                }
                self.onRestore?(restoredProducts)
            }
        }
    }
}
