//
//  PurchasedProductRow.swift
//  InAppPurchaseApp
//
//  Created by Vinicius Moreira Leal on 21/05/2021.
//

import SwiftUI

struct PurchasedProductRow: View {
    let title: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("\(title)")
                    .foregroundColor(.black)
            }
            .padding(.leading, 20)
            
            Spacer()
        }
        .frame(height: 90)
    }
}
