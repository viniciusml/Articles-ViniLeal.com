//
//  ProductsView.swift
//  InAppPurchaseApp
//
//  Created by Vinicius Moreira Leal on 07/04/2021.
//

import SwiftUI

struct ProductsView: View {
    let viewModel: ViewModel = ViewModel(products: [Product(id: 0, title: "A product", price: "3,99", isAvailable: true), Product(id: 2, title: "Another product", price: "Not available", isAvailable: false)])
    let onRestoreTap: () -> Void = {}
    let onBuyTap: () -> Void = {}
    
    var body: some View {
        VStack {
            Text("My Basket")
                .font(.largeTitle)
                .foregroundColor(.white)
                .padding(.top, 40)
            
            VStack(spacing: 20) {
                HStack {
                    Spacer()
                    Button(action: onRestoreTap, label: {
                        Text("Restore")
                            .foregroundColor(.black)
                            .font(.body)
                            .underline()
                            .padding([.top, .trailing], 20)
                    })
                }
                ForEach(viewModel.products) { product in
                    ProductRow(title: product.title, price: product.price, isAvailable: product.isAvailable, onBuyTap: onBuyTap)
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
