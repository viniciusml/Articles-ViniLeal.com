//
//  MainQueueDecorator+ProductResultHandling.swift
//  InAppPurchaseApp
//
//  Created by Vinicius Moreira Leal on 20/05/2021.
//

import Foundation
import InAppPurchase

protocol ProductResultCompletionHandling: ProductLoaderDelegate {
    var completion: ((ProductsResult) -> Void)? { get set }
}

typealias ProductResultHandling = ProductLoaderDelegate & ProductResultCompletionHandling

class ProductResultHandler: ProductResultHandling {
    
    var completion: ((ProductsResult) -> Void)?
    
    func didFetchProducts(with result: ProductsResult) {
        completion?(result)
    }
}

extension MainQueueDecorator: ProductResultHandling where T: ProductResultHandling {
    
    var completion: ((ProductsResult) -> Void)? {
        get {
            decoratee.completion
        }
        set {
            decoratee.completion = newValue
        }
    }
    
    func didFetchProducts(with result: ProductsResult) {
        DispatchQueue.main.async {
            self.decoratee.didFetchProducts(with: result)
        }
    }
}
