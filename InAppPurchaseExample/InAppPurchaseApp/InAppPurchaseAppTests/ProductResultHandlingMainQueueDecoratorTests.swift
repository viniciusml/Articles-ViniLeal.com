//
//  ProductResultHandlingMainQueueDecoratorTests.swift
//  InAppPurchaseAppTests
//
//  Created by Vinicius Moreira Leal on 23/05/2021.
//

@testable import InAppPurchaseApp
import InAppPurchase
import StoreKit
import XCTest

class ProductResultHandlingMainQueueDecoratorTests: XCTestCase {
    typealias Result = Swift.Result<[SKProduct], Error>
    
    func test_fetchProductsWithFailure_deliversResultInMainThread() {
        let expectedResult = Result.failure(anyNSError())
        ProductLoaderStub.stubbedResult = expectedResult
        let (productLoader, sut) = makeSUT()
        
        productLoader.fetchProducts()
        sut.completion = { receivedResult in
            XCTAssert(Thread.isMainThread)
            assertEqual(receivedResult.failure, expectedResult.failure)
        }
    }
    
    func test_fetchProductsWithSuccess_deliversResultInMainThread() {
        let expectedResult = Result.success([anyProduct()])
        ProductLoaderStub.stubbedResult = expectedResult
        let (productLoader, sut) = makeSUT()
        
        productLoader.fetchProducts()
        sut.completion = { receivedResult in
            XCTAssert(Thread.isMainThread)
            XCTAssertEqual(receivedResult.success, expectedResult.success)
        }
    }
    
    // MARK: - Helpers
    
    private class ProductLoaderStub: ProductLoading {
        
        static var stubbedResult: Result = .success([])
        var delegate: ProductLoaderDelegate?
        
        func fetchProducts() {
            DispatchQueue.global(qos: .background).async {
                self.delegate?.didFetchProducts(with: ProductLoaderStub.stubbedResult)
            }
        }
    }
    
    private func makeSUT() -> (productLoader: ProductLoading, sut: ProductResultHandling) {
        let productLoader = ProductLoaderStub()
        let sut = MainQueueDecorator(ProductResultHandler())
        productLoader.delegate = sut
        return (productLoader, sut)
    }
}
