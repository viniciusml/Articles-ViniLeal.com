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
            assertEqual(receivedResult.error, expectedResult.error)
        }
    }
    
    func test_fetchProductsWithSuccess_deliversResultInMainThread() {
        let expectedResult = Result.success([anyProduct()])
        ProductLoaderStub.stubbedResult = expectedResult
        let (productLoader, sut) = makeSUT()
        
        productLoader.fetchProducts()
        sut.completion = { receivedResult in
            XCTAssert(Thread.isMainThread)
            XCTAssertEqual(receivedResult.products, expectedResult.products)
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
    
    private func anyNSError() -> NSError {
        NSError(domain: "test error", code: 0)
    }
    
    private func anyProduct() -> SKProduct {
        SKProduct()
    }
}

private func assertEqual(_ receivedError: Error?, _ expectedError: Error?, _ message: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line) {
    XCTAssertEqual(receivedError as NSError?, expectedError as NSError?, file: file, line: line)
}

private extension Result where Success == [SKProduct] {
    
    var error: Error? {
        switch self {
        case let .failure(error):
            return error
        case .success:
            return nil
        }
    }
    
    var products: Success? {
        switch self {
        case let .success(products):
            return products
        case .failure:
            return nil
        }
    }
}
