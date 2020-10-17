//
//  SceneDelegate.swift
//  PageViewController
//
//  Created by Vinicius Moreira Leal on 22/04/2020.
//  Copyright © 2020 Vinicius Moreira Leal. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        
        let controller1 = makeController(.red)
        let controller2 = makeController(.green)
        let controller3 = makeController(.blue)
        let controller4 = makeController(.brown)
        let controller5 = makeController(.cyan)
        let controller6 = makeController(.orange)
        
        let pages = [controller1, controller2, controller3, controller4, controller5, controller6]
        
        window?.rootViewController = PageViewController(pages: pages)
        
        window?.makeKeyAndVisible()
    }
    
    private func makeController(_ color: UIColor) -> UIViewController {
        let controller = UIViewController()
        controller.view.backgroundColor = color
        return controller
    }
}
