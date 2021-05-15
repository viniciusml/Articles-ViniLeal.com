//
//  InAppPurchaseAppApp.swift
//  InAppPurchaseApp
//
//  Created by Vinicius Moreira Leal on 25/03/2021.
//

import InAppPurchase
import SwiftUI

@main
struct InAppPurchaseApp: App {
    
    let productLoader = ProductLoader(request: ProductRequestFactory.make(with: []))
    let observer = PurchaseObserver()
    
    var body: some Scene {
        WindowGroup {
            Color.green
                .ignoresSafeArea(.all)
                .overlay(ContentView(container: ProductViewContainer(observer: observer, onRestoreTap: {}, onBuyTap: {})))
        }
    }
    
    private func loadProducts() {
        productLoader.fetchProducts()
        productLoader.completion = { result in
            if let products = try? result.get() {
                observer.setViewModel(
                    ViewModel(products: products.map { Product(id: $0.productIdentifier, title: $0.localizedTitle, price: $0.price.stringValue) })
                )
            }
        }
    }
}
