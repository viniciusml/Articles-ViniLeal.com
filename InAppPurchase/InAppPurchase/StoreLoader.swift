//
//  StoreLoader.swift
//  InAppPurchase
//
//  Created by Vinicius Moreira Leal on 08/03/2021.
//

import StoreKit

// We could use an abstract factory, or an Adapter, which can drastically simplify the design. With a factory, your code needs to ask an object to return something. With an adapter, you tell objects to do somthing.

// The interface we want is 'fetchProducts(with identifiers: [String])'
public struct StoreLoaderFactory {
    public static func make(
        with identifiers: [String],
        request: (Set<String>) -> SKProductsRequest
    ) -> SKProductsRequest {
        
        request(Set(identifiers))
    }
}

public class StoreLoader: NSObject {
    private var request: SKProductsRequest
    
    public init(request: SKProductsRequest) {
        self.request = request
        super.init()
        self.request.delegate = self
    }
    
    public func fetchProducts() {
        request.start()
    }
}

extension StoreLoader: SKProductsRequestDelegate {
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
    }
}
