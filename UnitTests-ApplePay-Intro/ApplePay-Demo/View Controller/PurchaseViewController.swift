//
//  PurchaseViewController.swift
//  ApplePay-Demo
//
//  Created by Vinicius Leal on 24/09/2020.
//  Copyright © 2020 Vinicius Leal. All rights reserved.
//

import PassKit
import UIKit

public class PurchaseViewController: UIViewController {
    
    let paymentProvider: PaymentProvider
    let paymentAuthorizationHandler: PaymentAuthorizationHandler
        
    lazy public var paymentButton: PKPaymentButton = {
        let button = PKPaymentButton(paymentButtonType: .buy, paymentButtonStyle: .black)
        button.addTarget(self, action: #selector(didTapPay), for: .touchUpInside)
        button.constrainWidth(constant: self.view.frame.width - 40)
        button.constrainHeight(constant: 50)
        return button
    }()
    
    public init(paymentProvider: PaymentProvider, paymentAuthorizationHandler: PaymentAuthorizationHandler) {
        self.paymentProvider = paymentProvider
        self.paymentAuthorizationHandler = paymentAuthorizationHandler
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.addSubview(paymentButton)
        paymentButton.centerInSuperview()
    }
    
    @objc func didTapPay() {
        paymentAuthorizationHandler.requestAuthorization { completion in
            switch completion {
                case let .success(controller):
                    controller.delegate = self
                    present(controller, animated: true)
                case let .failure(error):
                    // Handle error case
                    debugPrint("\(error)")
            }
        }
    }
}

extension PurchaseViewController: PKPaymentAuthorizationViewControllerDelegate {
    public func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true)
    }
    
    public func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        
        paymentProvider.processPayment(payment) { error in
            if error != nil {
                completion(.failure)
            } else {
                completion(.success)
            }
        }
    }
}
