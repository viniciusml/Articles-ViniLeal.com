//
//  StoreLoader.swift
//  InAppPurchase
//
//  Created by Vinicius Moreira Leal on 08/03/2021.
//

import StoreKit

public protocol Request {
    var delegate: SKProductsRequestDelegate? { get set }
    init(productIdentifiers: Set<String>)
    func start()
}

extension SKProductsRequest: Request {}

// We could use an abstract factory, or an Adapter, which can drastically simplify the design. With a factory, your code needs to ask an object to return something. With an adapter, you tell objects to do somthing.

// The interface we want is 'fetchProducts(with identifiers: [String])'
public class StoreLoaderAdapter {
    private let factory: (Set<String>) -> Request
    private let identifiers: [String]
    
    public init(identifiers: [String],
                factory: @escaping (Set<String>) -> Request = SKProductsRequest.init(productIdentifiers:)) {
        self.identifiers = identifiers
        self.factory = factory
    }
    
    public func createRequest() -> Request {
        let productIdentifiers = Set(identifiers)
        
        return factory(productIdentifiers)
    }
}

public class StoreLoader: NSObject {
    private var request: Request
    
    public init(request: Request) {
        self.request = request
        super.init()
        self.request.delegate = self
    }
}

extension StoreLoader: SKProductsRequestDelegate {
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
    }
}
