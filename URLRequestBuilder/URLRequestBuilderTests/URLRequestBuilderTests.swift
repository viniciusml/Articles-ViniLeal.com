//
//  URLRequestBuilderTests.swift
//  URLRequestBuilderTests
//
//  Created by Vinicius Moreira Leal on 06/05/2020.
//  Copyright © 2020 Vinicius Moreira Leal. All rights reserved.
//

import XCTest

protocol RequestBuilder {
    func build(from host: URL) -> URLRequest
}

class URLRequestBuilder {
    
    func build(from host: URL) -> URLRequest {
        return URLRequest(url: host)
    }
}

class URLRequestBuilderTests: XCTestCase {

    func test_build_usesCorrectHostURL() {
        let sut = URLRequestBuilder()
        let url = URL(string: "http://any-url.com")!
        
        let request = sut.build(from: url)
        
        XCTAssertEqual(request.url, url)
    }
}
