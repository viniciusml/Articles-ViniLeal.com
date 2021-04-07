//
//  ContentView.swift
//  InAppPurchaseApp
//
//  Created by Vinicius Moreira Leal on 25/03/2021.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ProductsView()
    }
}

struct Product: Identifiable {
    let id: Int
    let title: String
    let price: String
}

struct ViewModel {
    let products: [Product]
}

struct ProductsView: View {
    let viewModel: ViewModel = ViewModel(products: [Product(id: 0, title: "A product", price: "3,99"), Product(id: 2, title: "Another product", price: "Not available")])
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
                    ProductRow(title: product.title, price: product.price, onBuyTap: onBuyTap)
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

struct ProductRow: View {
    let title: String
    let price: String
    let onBuyTap: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("\(title)")
                Text(price)
                    .font(.subheadline)
            }
            .padding(.leading, 20)
            
            Spacer()
            
            Button("Buy", action: onBuyTap)
                .foregroundColor(.blue)
                .padding(.trailing, 20)
        }
        .frame(height: 90)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Color.green
            .ignoresSafeArea(.all)
            .overlay(ContentView())
    }
}
