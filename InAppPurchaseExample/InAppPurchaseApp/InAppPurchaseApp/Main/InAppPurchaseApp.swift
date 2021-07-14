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
    
    let productCoordinator = PurchaseCoordinator(
        productLoader: ProductLoader(request: ProductRequestFactory.make(with: IDLoader.ids)),
        transactionObserver: PaymentTransactionObserver(),
        productResultHandler: MainQueueDecorator(ProductResultHandler()),
        transactionHandler: MainQueueDecorator(PaymentTransactionHandler())
    )
    
    let observer = PurchaseObserver()
    
    var body: some Scene {
        WindowGroup {
            Color.green
                .ignoresSafeArea(.all)
                .overlay(ContentView(observer: observer,
                                     actionContainer: ActionContainer(onRestoreTap: productCoordinator.restorePurchasedProducts,
                                                                      onBuyTap: { _ in }))) // String -> SKProduct
                .onAppear(perform: productCoordinator.loadProducts)
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
