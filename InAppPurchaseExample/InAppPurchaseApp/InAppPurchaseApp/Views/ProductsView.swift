//
//  ProductsView.swift
//  InAppPurchaseApp
//
//  Created by Vinicius Moreira Leal on 07/04/2021.
//

import SwiftUI

struct ProductsView: View {
    @ObservedObject var observer: PurchaseObserver
    let actionContainer: ActionContainer
    
    var body: some View {
        VStack {
            Text("My Basket")
                .font(.largeTitle)
                .foregroundColor(.white)
                .padding(.top, 40)
            
            VStack(spacing: 20) {
                HStack {
                    Spacer()
                    Button(action: actionContainer.onRestoreTap, label: {
                        Text("Restore")
                            .foregroundColor(.black)
                            .font(.body)
                            .underline()
                            .padding([.top, .trailing], 20)
                    })
                }
                ForEach(observer.products) { product in
                    ProductRow(title: product.title, price: product.price, onBuyTap: actionContainer.onBuyTap)
                        .cornerRadius(12)
                        .background(Color.white.shadow(color: Color.black.opacity(0.15), radius: 3))
                        .padding(.horizontal, 12)
                }
                Spacer()
            }
            .background(Color.white)
            .cornerRadius(20.0)
            .ignoresSafeArea(.all, edges: .bottom)
            .padding(.top, 40)
        }
    }
}
