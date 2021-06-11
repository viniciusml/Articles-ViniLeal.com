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
            guard let self = self,
                  let products = try? result.get() else { return }
            
            let availableProducts = products.map(AvailableProduct.init)
            self.availableProducts = availableProducts
            self.onLoad?(availableProducts)
        }
    }
    
    func restorePurchasedProducts() {
        transactionObserver.restore()
        transactionHandler.completion = { [weak self] result in
            guard let self = self,
                  let transactions = try? result.get() else { return }
            
            let restoredProducts = transactions.reduce(([PurchasedProduct]())) { accumulator, value in
                var accumulatorCopy = accumulator
                if let product = self.availableProducts.firstMatching(value.identifier) {
                    accumulatorCopy.append(PurchasedProduct(product))
                }
                return accumulatorCopy
            }
            
            self.onRestore?(restoredProducts)
        }
    }
}

private extension AvailableProduct {
    
    init(_ product: SKProduct) {
        self.init(id: product.productIdentifier,
                  title: product.localizedTitle,
                  price: product.price.stringValue)
    }
}

private extension Array where Element == AvailableProduct {
    
    func firstMatching(_ id: String) -> Element? {
        first(where: { $0.id == id })
    }
}

private extension PurchasedProduct {
    
    init(_ product: AvailableProduct) {
        self.init(id: product.id, title: product.title)
    }
}
