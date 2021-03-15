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
        let expectedError = anyNSError()
        
        sut.fetchProducts()
        
        expect(sut, toCompleteWith: .failure(expectedError), when: {
            request.completeWith(expectedError)
        })
    }
    
    func test_completesWithResponse_onRequestSuccess() {
        let (request, sut) = makeSUT()
        let expectedProductsResponse = anyProductsResponse(id: "test response")
        
        sut.fetchProducts()
        
        expect(sut, toCompleteWith: .success(expectedProductsResponse), when: {
            request.completeWith(expectedProductsResponse)
        })
    }
    
    func test_fetchProducts_doesNotMakeNewRequestWhileProductsAreBeingFetched() {}
    
    // MARK: - Helpers
    
    private func makeSUT() -> (request: ProductsRequestSpy, sut: StoreLoader) {
        let request = ProductsRequestSpy()
        let sut = StoreLoader(request: request)
        return (request, sut)
    }
    
    private func expect(_ sut: StoreLoader, toCompleteWith expectedResult: StoreLoader.ProductsResult, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        sut.completion = { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedResponse), .success(expectedResponse)):
                XCTAssertEqual(receivedResponse, expectedResponse, file: file, line: line)
                
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
        }
        action()
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
