//
//  ContentView.swift
//  InAppPurchaseApp
//
//  Created by Vinicius Moreira Leal on 25/03/2021.
//

import SwiftUI

struct ActionContainer {
    let onRestoreTap: () -> Void
    let onBuyTap: (String) -> Void
}

struct ContentView: View {
    @ObservedObject var observer: PurchaseObserver
    let actionContainer: ActionContainer
    
    var body: some View {
        ProductsView(observer: observer, actionContainer: actionContainer)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Color.green
            .ignoresSafeArea(.all)
            .overlay(ContentView(
                        observer: PurchaseObserver(
                            viewModel: ViewModel(availableProducts: [], purchasedProducts: [])),
                        actionContainer: ActionContainer(onRestoreTap: {}, onBuyTap: { _ in })))
    }
}
