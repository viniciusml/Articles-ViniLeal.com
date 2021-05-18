//
//  StoreLoader.swift
//  InAppPurchase
//
//  Created by Vinicius Moreira Leal on 08/03/2021.
//

import StoreKit

public struct ProductRequestFactory {
    public static func make(
        with identifiers: [String],
        request: (Set<String>) -> SKProductsRequest = SKProductsRequest.init(productIdentifiers:)
    ) -> SKProductsRequest {
        
        request(Set(identifiers))
    }
}

public protocol ProductLoading {
    typealias ProductsResult = Result<[SKProduct], Error>
    
    var completion: ((ProductsResult) -> Void)? { get set }
    func fetchProducts()
}

public class ProductLoader: NSObject, ProductLoading {
    public typealias ProductsResult = Result<[SKProduct], Error>
    
    private var request: SKProductsRequest
    public var completion: ((ProductsResult) -> Void)?
    
    public init(request: SKProductsRequest) {
        self.request = request
        super.init()
        self.request.delegate = self
    }
    
    public func fetchProducts() {
        request.start()
    }
}

extension ProductLoader: SKProductsRequestDelegate {
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        completion?(.success(response.products))
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        completion?(.failure(error))
        requestDidFinish(request)
    }
    
    public func requestDidFinish(_ request: SKRequest) {
        request.cancel()
    }
}
