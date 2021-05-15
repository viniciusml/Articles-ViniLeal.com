//
//  ProductRow.swift
//  InAppPurchaseApp
//
//  Created by Vinicius Moreira Leal on 07/04/2021.
//

import SwiftUI

struct ProductRow: View {
    let title: String
    let price: String
    let onBuyTap: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("\(title)")
                Text(price)
                    .font(.subheadline)
            }
            .padding(.leading, 20)
            
            Spacer()
            
            Button("Buy", action: onBuyTap)
                .foregroundColor(.green)
                .padding(.trailing, 20)
        }
        .frame(height: 90)
    }
}
