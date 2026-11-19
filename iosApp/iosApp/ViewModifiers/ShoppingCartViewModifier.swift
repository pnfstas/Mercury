//
//  ShoppingCartViewModifier.swift
//  iosApp
//
//  Created by Panferov Stanislav on 13.08.2026.
//

import SwiftUI
import shared

struct ShoppingCartViewModifier: ViewModifier {
    var viewModel : MercuryShopViewModel
    @Environment(\.screenSize) private var screenSize
    func body(content: Content) -> some View {
        let buttonOpacity : CGFloat = viewModel.cartUIStates.isEmpty ? 0.5 : 1
        if viewModel.isShoppingCartOpen {
            content
                .overlay(alignment: .center) {
                    ZStack {
                        Color.black.opacity(0.4)
                            .contentShape(Rectangle())
                            .ignoresSafeArea()
                            .onTapGesture {
                                viewModel.isShoppingCartOpen = false
                            }
                        VStack(alignment: .center, spacing: 10) {
                            HStack(alignment: .center) {
                                IconButton(action: { viewModel.isShoppingCartOpen = false }, image: "Closed", width: 15, height: 15, padding: 10, shape: Circle(), backgroundColor: .red)
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            Divider()
                                .frame(maxWidth: .infinity, maxHeight: 2, alignment: .leading)
                            ScrollView([.horizontal, .vertical]) {
                                LazyVStack(alignment: .leading, spacing: 7) {
                                    ForEach(viewModel.cartUIStates, id: \.productId) { cartUIState in
                                        let productId : Int = Int(truncating: NSNumber(value: cartUIState.productId))
                                        let element : ProductUIStateTuple? = viewModel.productUIStates.first { $0.productId == productId }
                                        if let product = element?.uiState {
                                            HStack(alignment: .center, spacing: 2) {
                                                AsyncImage(url: URL(string: product.image)) { image in
                                                    image
                                                        .resizable()
                                                        .scaledToFit()
                                                } placeholder: {
                                                    ProgressView()
                                                }
                                                .frame(width: screenSize.width / 8, height: screenSize.width / 8)
                                                VStack(alignment: .center, spacing: 10) {
                                                    Text(product.title)
                                                    Text(product.descr)
                                                }
                                                .frame(maxWidth: .infinity)
                                                Text(product.priceDescr)
                                                    .frame(width: screenSize.width / 8)
                                                HStack(alignment: .center) {
                                                    IconButton(action: { viewModel.decreaseShoppingCartQuantity(cartUIState: cartUIState) }, systemImage: "minus")
                                                    TextField("", value: viewModel.bindShoppingCartQuantity(cartUIState: cartUIState), format: .number)
                                                        .keyboardType(.decimalPad)
                                                        .frame(width: 20, height: 22)
                                                    IconButton(action: { viewModel.increaseShoppingCartQuantity(cartUIState: cartUIState) }, systemImage: "plus")
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
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .scrollIndicators(.visible, axes: [.horizontal, .vertical])
                            .background(.clear)
                            HStack(alignment: .center, spacing: 20) {
                                DialogButton(action: { viewModel.clearShoppingCart() }, label: "Очистить корзину", width: screenSize.width / 3,
                                    opacity: buttonOpacity)
                                DialogButton(action: { viewModel.createOrder() }, label: "Сформировать заказ", width: screenSize.width / 3,
                                    opacity: buttonOpacity)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .frame(maxWidth: screenSize.width * 0.8, maxHeight: screenSize.height * 0.8)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 10)
                        .background(RoundedRectangle(cornerRadius: 8).fill(.white))
                        .onTapGesture { }
                    }
                }
            }
        else {
            content
        }
    }
}
extension View {
    func shoppingCart(viewModel : MercuryShopViewModel) -> some View {
        modifier(ShoppingCartViewModifier(viewModel : viewModel))
    }
}
