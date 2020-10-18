//
//  SceneDelegate.swift
//  ApplePay-Demo
//
//  Created by Vinicius Leal on 24/09/2020.
//  Copyright © 2020 Vinicius Leal. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene

        let paymentProvider = RemotePaymentProvider()
        let paymentAuthorizationHandler = PaymentAuthorizationHandler()
        
        window?.rootViewController = PurchaseViewController(
            paymentProvider: paymentProvider,
            paymentAuthorizationHandler: paymentAuthorizationHandler)
        
        window?.makeKeyAndVisible()
    }
}

