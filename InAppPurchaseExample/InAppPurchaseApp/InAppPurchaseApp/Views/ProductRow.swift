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
    let isAvailable: Bool
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
                .opacity(isAvailable ? 1.0 : 0.6)
                .padding(.trailing, 20)
                .disabled(!isAvailable)
        }
        .frame(height: 90)
    }
}
