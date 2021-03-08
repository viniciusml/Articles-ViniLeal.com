//
//  StoreLoader.swift
//  InAppPurchase
//
//  Created by Vinicius Moreira Leal on 08/03/2021.
//

import StoreKit

public class StoreLoader {
    let request: (Set<String>) -> SKProductsRequest
    
    public init(request: @escaping (Set<String>) -> SKProductsRequest = SKProductsRequest.init(productIdentifiers:)) {
        self.request = request
    }
}
