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
    
    let productLoader = ProductLoader(request: ProductRequestFactory.make(with: IDLoader.ids))
    let observer = PurchaseObserver()
    
    var body: some Scene {
        WindowGroup {
            Color.green
                .ignoresSafeArea(.all)
                .overlay(ContentView(container: ProductViewContainer(observer: observer, onRestoreTap: {}, onBuyTap: {})))
                .overlay(ContentView(observer: observer, actionContainer: ActionContainer(onRestoreTap: {}, onBuyTap: {})))
                .onAppear(perform: loadProducts)
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

struct IDLoader {
    static var ids: [String] {
        guard let url = Bundle.main.url(forResource: "product_ids", withExtension: "plist") else {
            fatalError("Unable to resolve url for in the bundle.")
        }
        do {
            let data = try Data(contentsOf: url)
            let productIdentifiers = try PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: nil) as? [String]
            return productIdentifiers ?? []
        } catch let error as NSError {
            print("\(error.localizedDescription)")
            return []
        }
    }
}
