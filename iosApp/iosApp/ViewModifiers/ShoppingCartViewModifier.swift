//
//  ShoppingCartViewModifier.swift
//  iosApp
//
//  Created by Panferov Stanislav on 13.08.2026.
//

import SwiftUI

struct ShoppingCartViewModifier: ViewModifier {
    @Binding var mercuryShopViewModel : MercuryShopViewModel
    @Binding var isShoppingCartOpen : Bool
    let screenWidth : CGFloat = UIScreen.main.bounds.width
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .center) {
                if isShoppingCartOpen {
                    ZStack {
                        Color.black.opacity(0.4)
                            .contentShape(Rectangle())
                            .ignoresSafeArea()
                            .onTapGesture {
                                isShoppingCartOpen = false
                            }
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
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.7, maxHeight: UIScreen.main.bounds.height * 0.7)
                        .scrollIndicators(.automatic, axes: .horizontal)
                        .scrollIndicators(.automatic, axes: .vertical)
                        .background(RoundedRectangle(cornerRadius: 8).fill(.white))
                        .onTapGesture { }
                    }
                }
            }
            /*
            .background {
                if isShoppingCartOpen {
                    GeometryReader { proxy in
                        Color.black.opacity(0.001)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                isShoppingCartOpen = false
                            }
                            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                            .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
                    }
                    .ignoresSafeArea()
                }
            }
            */
    }
}
extension View {
    func shoppingCart(mercuryShopViewModel: Binding<MercuryShopViewModel>, isShoppingCartOpen: Binding<Bool>) -> some View {
        modifier(ShoppingCartViewModifier(mercuryShopViewModel: mercuryShopViewModel, isShoppingCartOpen: isShoppingCartOpen))
    }
}
