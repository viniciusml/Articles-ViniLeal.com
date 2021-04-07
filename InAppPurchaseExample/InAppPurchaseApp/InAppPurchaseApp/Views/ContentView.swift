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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Color.green
            .ignoresSafeArea(.all)
            .overlay(ContentView())
    }
}
