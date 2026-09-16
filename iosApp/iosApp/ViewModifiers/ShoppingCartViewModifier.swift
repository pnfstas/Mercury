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
    let screenHeight : CGFloat = UIScreen.main.bounds.height
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
                        VStack(alignment: .center, spacing: 10) {
                            HStack(alignment: .center) {
                                IconButton(action: { isShoppingCartOpen = false }, image: "Closed", width: 15, height: 15, padding: 10, shape: Circle(), backgroundColor: .red)
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            Divider()
                                .frame(maxWidth: .infinity, maxHeight: 2, alignment: .leading)
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
                                            HStack(alignment: .center) {
                                                IconButton(action: { mercuryShopViewModel.decreaseShoppingCartQuantity(cartUIState: cartUIState) }, systemImage: "minus")
                                                TextField("", value: mercuryShopViewModel.bindShoppingCartQuantity(cartUIState: cartUIState), format: .number)
                                                    .keyboardType(.decimalPad)
                                                    .frame(width: 20, height: 22)
                                                IconButton(action: { mercuryShopViewModel.increaseShoppingCartQuantity(cartUIState: cartUIState) }, systemImage: "plus")
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
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .scrollIndicators(.automatic, axes: .horizontal)
                            .scrollIndicators(.automatic, axes: .vertical)
                            .background(.clear)
                            Button(action: { mercuryShopViewModel.createOrder() }) {
                                Text("Сформировать заказ")
                                    .multilineTextAlignment(.center)
                            }
                            .buttonStyle(.plain)
                            .frame(width: screenWidth / 3, height: 40)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 5)
                            .foregroundStyle(.white)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color(.main)))
                            .opacity(mercuryShopViewModel.cartUIStates.isEmpty ? 0.5 : 1)
                            .font(.custom("Arial", size: 14).weight(.bold))

                        }
                        .frame(maxWidth: screenWidth * 0.8, maxHeight: screenHeight * 0.8)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 10)
                        .background(RoundedRectangle(cornerRadius: 8).fill(.white))
                        .onTapGesture { }
                        //.safeAreaInset(edge: .top, alignment: .center)
                    }
                }
            }
    }
}
extension View {
    func shoppingCart(mercuryShopViewModel: Binding<MercuryShopViewModel>, isShoppingCartOpen: Binding<Bool>) -> some View {
        modifier(ShoppingCartViewModifier(mercuryShopViewModel: mercuryShopViewModel, isShoppingCartOpen: isShoppingCartOpen))
    }
}
