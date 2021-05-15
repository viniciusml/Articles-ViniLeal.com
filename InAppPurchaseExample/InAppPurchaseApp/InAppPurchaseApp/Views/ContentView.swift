//
//  ContentView.swift
//  InAppPurchaseApp
//
//  Created by Vinicius Moreira Leal on 25/03/2021.
//

import SwiftUI

struct ProductViewContainer {
    let observer: PurchaseObserver
    let onRestoreTap: () -> Void
    let onBuyTap: () -> Void
}

struct ContentView: View {
    let container: ProductViewContainer
    
    var body: some View {
        ProductsView(container: container)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Color.green
            .ignoresSafeArea(.all)
            .overlay(ContentView(
                        container: ProductViewContainer(
                            observer: PurchaseObserver(
                                viewModel: ViewModel(
                                    products: [])),
                            onRestoreTap: {},
                            onBuyTap: {})))
    }
}
