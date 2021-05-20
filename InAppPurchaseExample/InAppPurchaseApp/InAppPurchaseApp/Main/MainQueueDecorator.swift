//
//  MainQueueDecorator.swift
//  InAppPurchaseApp
//
//  Created by Vinicius Moreira Leal on 20/05/2021.
//

import Foundation

class MainQueueDecorator<T> {
    private(set) var decoratee: T
    
    init(_ decoratee: T) {
        self.decoratee = decoratee
    }
}
