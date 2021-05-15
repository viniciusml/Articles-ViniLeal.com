//
//  Product.swift
//  InAppPurchaseApp
//
//  Created by Vinicius Moreira Leal on 07/04/2021.
//

import Foundation

struct Product: Identifiable {
    let id: Int
    let title: String
    let price: String
    let isAvailable: Bool
}
