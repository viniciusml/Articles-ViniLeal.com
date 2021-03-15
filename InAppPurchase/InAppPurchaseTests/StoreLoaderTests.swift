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
        let (request, sut) = makeSUT()

        XCTAssertTrue(request.delegate === sut)
    }
    
    func test_fetchProducts_startsRequest() {
        let (request, sut) = makeSUT()
        
        sut.fetchProducts()
        
        XCTAssertEqual(request.messages, [.start])
    }
    
    func test_completeWithError_onRequestFailure() {
        let (request, sut) = makeSUT()
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
        request.completeWith(anyNSError())
        
        wait(for: [exp], timeout: 0.1)
        XCTAssertEqual(expectedError, anyNSError())
    }
    
    func test_completesWithResponse_onRequestSuccess() {
        let (request, sut) = makeSUT()
        let expectedProductsResponse = anyProductsResponse(id: "test response")
        let exp = expectation(description: "Wait for completion")
        var receivedProductsResponse: SKProductsResponse?
        
        sut.fetchProducts()
        
        sut.completion = { receivedResult in
            switch receivedResult {
            case let .success(response):
                receivedProductsResponse = response
                exp.fulfill()
            case .failure:
                XCTFail("expected success, received failure instead.")
            }
        }
        request.completeWith(expectedProductsResponse)
        
        wait(for: [exp], timeout: 0.1)
        XCTAssertEqual(receivedProductsResponse, expectedProductsResponse)
    }
    
    func test_fetchProducts_doesNotMakeNewRequestWhileProductsAreBeingFetched() {}
    
    // MARK: - Helpers
    
    private func makeSUT() -> (request: ProductsRequestSpy, sut: StoreLoader) {
        let request = ProductsRequestSpy()
        let sut = StoreLoader(request: request)
        return (request, sut)
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "test", code: 0)
    }
    
    private func anyProductsResponse(id: String) -> SKProductsResponse {
        FakeProductsResponse(id: id)
    }
}

class FakeProductsResponse: SKProductsResponse {
    private(set) var responseID: String
    
    init(id: String) {
        self.responseID = id
        super.init()
    }
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
