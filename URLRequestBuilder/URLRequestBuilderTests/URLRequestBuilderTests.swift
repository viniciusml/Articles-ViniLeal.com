//
//  URLRequestBuilderTests.swift
//  URLRequestBuilderTests
//
//  Created by Vinicius Moreira Leal on 06/05/2020.
//  Copyright © 2020 Vinicius Moreira Leal. All rights reserved.
//

// http://test.myAPI.com/anyEndpoint/?width=200&height=200
// http://api.myAPI.com/anyEndpoint/?width=200&height=200

//func desiredResult() {
//    buildRequest(base: URL)
//        .path(.endpoint)
//        .query([queryItems])
//        .method(.get)
//}

import XCTest

protocol RequestBuilder {
    func build(from host: URL) -> URLRequest
}

class URLRequestBuilder {
    
    func build(from host: URL) -> URLRequest {
        return URLRequest(url: host)
    }
}

extension URLRequest {
    func method(_ method: String) -> URLRequest {
        var request = self
        request.httpMethod = method
        return request
    }
}

class URLRequestBuilderTests: XCTestCase {

    func test_build_usesCorrectHostURL() {
        let sut = URLRequestBuilder()
        let url = URL(string: "http://any-url.com")!
        
        let request = sut.build(from: url)
        
        XCTAssertEqual(request.url, url)
    }
    
    func test_build_setsHTTPMethod() {
        let sut = URLRequestBuilder()
        let url = URL(string: "http://any-url.com")!
        
        let request = sut.build(from: url)
                         .method("GET")
        
        XCTAssertEqual(request.httpMethod, "GET")
    }
}
