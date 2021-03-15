//
//  StoreLoaderTests.swift
//  InAppPurchaseTests
//
//  Created by Vinicius Moreira Leal on 08/03/2021.
//

import InAppPurchase
import StoreKit
import XCTest

class StoreLoaderAdapterTests: XCTestCase {
    
    func test_adapter_createsProperRequest() {
        let identifiers = ["id1", "id2"]
        
        _ = StoreLoaderFactory.make(
            with: identifiers,
            request: { mappedIdentifiers in
                
                XCTAssertTrue(mappedIdentifiers.isSubset(of: identifiers))
                return ProductsRequestSpy.any
            })
    }
}

class StoreLoaderTests: XCTestCase {

    func test_init_setsDelegate() {
        let request = ProductsRequestSpy()
        let sut = StoreLoader(request: request)

        XCTAssertTrue(request.delegate === sut)
    }
    
    func test_fetchProducts_startsRequest() {
        let request = ProductsRequestSpy()
        let sut = StoreLoader(request: request)
        
        sut.fetchProducts()
        
        XCTAssertEqual(request.messages, [.start])
    }
    
    func test_completeWithError_onRequestFailure() {
        let request = ProductsRequestSpy()
        let sut = StoreLoader(request: request)
        let exp = expectation(description: "Wait for completion")
        var expectedError: NSError?
        
        sut.fetchProducts()
        
        sut.completion = { receivedResult in
            switch receivedResult {
            case .success:
                XCTFail("expected failure, received success instead.")
            case let .failure(error as NSError):
                expectedError = error
                exp.fulfill()
            }
        }
        request.completeWith(NSError(domain: "test", code: 0))
        
        wait(for: [exp], timeout: 0.1)
        XCTAssertEqual(expectedError, NSError(domain: "test", code: 0))
    }
    
    func test_completesWithProducts_onRequestSuccess() {}
    
    func test_fetchProducts_doesNotMakeNewRequestWhileProductsAreBeingFetched() {}
}

class ProductsRequestSpy: SKProductsRequest {
    enum Message {
        case start
    }
    
    private var error: Error?
    private var response: SKProductsResponse?
    
    private(set) var messages = [Message]()
    private(set) var identifiers = Set<String>()
    
    override init(productIdentifiers: Set<String> = Set()) {
        identifiers = productIdentifiers
        super.init()
    }
    
    override func start() {
        messages.append(.start)
    }

    public func completeWith(_ error: Error) {
        delegate?.request!(self, didFailWithError: error)
    }
    
    public func completeWith(_ response: SKProductsResponse) {
        delegate?.productsRequest(self, didReceive: response)
    }
}

extension ProductsRequestSpy {
    static var any: ProductsRequestSpy {
        ProductsRequestSpy(productIdentifiers: Set<String>())
    }
}
