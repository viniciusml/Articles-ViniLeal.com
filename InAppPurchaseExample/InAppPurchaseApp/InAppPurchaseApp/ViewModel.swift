//
//  ViewModel.swift
//  InAppPurchaseApp
//
//  Created by Vinicius Moreira Leal on 07/04/2021.
//

import Foundation

class ViewModel: ObservableObject {

    private(set) var products: [Product]
    
    init(products: [Product]) {
        self.products = products
    }
}
