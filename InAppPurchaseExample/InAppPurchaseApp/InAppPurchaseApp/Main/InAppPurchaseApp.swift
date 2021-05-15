//
//  InAppPurchaseAppApp.swift
//  InAppPurchaseApp
//
//  Created by Vinicius Moreira Leal on 25/03/2021.
//

import SwiftUI

@main
struct InAppPurchaseApp: App {
    var body: some Scene {
        WindowGroup {
            Color.green
                .ignoresSafeArea(.all)
                .overlay(ContentView())
        }
    }
}
