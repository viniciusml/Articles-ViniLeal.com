//
//  ViewModel.swift
//  InAppPurchaseApp
//
//  Created by Vinicius Moreira Leal on 07/04/2021.
//

import Foundation

class PurchaseObserver: ObservableObject {
    private(set) var viewModel: ViewModel
    
    var availableProducts: [AvailableProduct] {
        viewModel.availableProducts
    }
    
    var purchasedProducts: [PurchasedProduct] {
        viewModel.purchasedProducts
    }
    
    init(viewModel: ViewModel = .empty) {
        self.viewModel = viewModel
    }
    
    func setViewModel(_ newViewModel: ViewModel) {
        viewModel = newViewModel
        
        objectWillChange.send()
    }
}

struct ViewModel {
    private(set) var availableProducts: [AvailableProduct]
    private(set) var purchasedProducts: [PurchasedProduct]
    
    init(availableProducts: [AvailableProduct], purchasedProducts: [PurchasedProduct]) {
        self.availableProducts = availableProducts
        self.purchasedProducts = purchasedProducts
    }
}

private extension ViewModel {
    static var empty: ViewModel {
        ViewModel(availableProducts: [], purchasedProducts: [])
    }
}
