//
//  ShoppingCartViewModifier.swift
//  iosApp
//
//  Created by Panferov Stanislav on 13.08.2026.
//

import SwiftUI

struct ShoppingCartViewModifier: ViewModifier {
    @Binding var mercuryShopViewModel : MercuryShopViewModel
    let screenWidth : CGFloat = UIScreen.main.bounds.width
    func body(content: Content) -> some View {
        content
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 7) {
                ForEach(mercuryShopViewModel.cartUIStates, id: \.product.id) { cartUIState in
                    HStack(alignment: .center, spacing: 2) {
                        AsyncImage(url: URL(string: cartUIState.product.image)) { image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                            .frame(width: screenWidth / 8, height: screenWidth / 8)
                         VStack(alignment: .center, spacing: 10) {
                            Text(cartUIState.product.title)
                            Text(cartUIState.product.descr)
                        }
                            .frame(maxWidth: .infinity)
                        Text(cartUIState.product.priceDescr)
                            .frame(width: screenWidth / 8)
                        HStack {
                            Button("", systemImage: "minus", action: { mercuryShopViewModel.decreaseShoppingCartQuantity(cartUIState: cartUIState) })
                            .buttonStyle(.plain)
                            .frame(width: 15, height: 22)
                            TextField("", value: mercuryShopViewModel.bindShoppingCartQuantity(cartUIState: cartUIState), format: .number)
                                .keyboardType(.decimalPad)
                                .frame(width: 20, height: 22)
                            Button("", systemImage: "plus", action: { mercuryShopViewModel.increaseShoppingCartQuantity(cartUIState: cartUIState) })
                            .buttonStyle(.plain)
                            .frame(width: 15, height: 22)
                        }
                        .overlay(Rectangle().stroke(.black, lineWidth: 2))
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.black)
                    .background(.clear)
                    .font(.custom("Arial", size: 12).weight(.regular))
                }
            }
        }
        .scrollIndicators(.automatic, axes: .horizontal)
        .scrollIndicators(.automatic, axes: .vertical)
    }
}
extension View {
    func shoppingCart(mercuryShopViewModel: Binding<MercuryShopViewModel>) -> some View {
        modifier(ShoppingCartViewModifier(mercuryShopViewModel: mercuryShopViewModel))
    }
}
