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

extension URL {
    func buildRequest() -> URLRequest {
        return URLRequest(url: self)
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
        let url = URL(string: "http://any-url.com")!
        
        let request = url.buildRequest()
        
        XCTAssertEqual(request.url, url)
    }
    
    func test_build_setsHTTPMethod() {
        let url = URL(string: "http://any-url.com")!
        
        let request = url.buildRequest()
                         .method("GET")
        
        XCTAssertEqual(request.httpMethod, "GET")
    }
}
