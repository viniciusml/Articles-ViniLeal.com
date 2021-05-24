//
//  TestHelpers.swift
//  InAppPurchaseAppTests
//
//  Created by Vinicius Moreira Leal on 24/05/2021.
//

import StoreKit
import XCTest

func assertEqual(_ receivedError: Error?, _ expectedError: Error?, _ message: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line) {
    XCTAssertEqual(receivedError as NSError?, expectedError as NSError?, file: file, line: line)
}

func anyNSError() -> NSError {
    NSError(domain: "test error", code: 0)
}

func anyProduct() -> SKProduct {
    SKProduct()
}

extension Result {
    
    var failure: Error? {
        switch self {
        case let .failure(failure):
            return failure
        case .success:
            return nil
        }
    }
    
    var success: Success? {
        switch self {
        case let .success(success):
            return success
        case .failure:
            return nil
        }
    }
}
