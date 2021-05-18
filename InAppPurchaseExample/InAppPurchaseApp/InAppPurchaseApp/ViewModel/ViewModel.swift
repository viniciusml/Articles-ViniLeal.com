//
//  ViewModel.swift
//  InAppPurchaseApp
//
//  Created by Vinicius Moreira Leal on 07/04/2021.
//

import Foundation
import InAppPurchase

class PurchaseObserver: ObservableObject {
    private(set) var viewModel: ViewModel
    
    var products: [Product] {
        viewModel.products
    }
    
    init(viewModel: ViewModel = ViewModel(products: [])) {
        self.viewModel = viewModel
    }
    
    func setViewModel(_ newViewModel: ViewModel) {
        viewModel = newViewModel
        
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
}

struct ViewModel {
    private(set) var products: [Product]
    
    init(products: [Product]) {
        self.products = products
    }
}
