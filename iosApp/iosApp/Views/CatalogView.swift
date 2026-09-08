//
//  Catalog.swift
//  iosApp
//
//  Created by Panferov Stanislav on 13.08.2026.
//

import SwiftUI
import shared

struct CatalogView: View {
    @Binding var mercuryShopViewModel : MercuryShopViewModel
    let screenWidth : CGFloat = UIScreen.main.bounds.width
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 7) {
                ForEach(mercuryShopViewModel.shopUIStates, id: \.id) { shopUIState in
                    HStack(alignment: .center, spacing: 5) {
                        AsyncImage(url: URL(string: shopUIState.product.image)) { image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                            .frame(width: screenWidth / 8, height: screenWidth / 8)
                            .background(.clear)
                        VStack(alignment: .center, spacing: 10) {
                            Text(shopUIState.product.title)
                            Text(shopUIState.product.descr)
                        }
                        Text(shopUIState.product.priceDescr)
                            .frame(maxWidth: .infinity)
                        HStack {
                            Button("-", action: { mercuryShopViewModel.decreaseQuantityInShoppingCart(shopUIState: shopUIState) })
                            .buttonStyle(.plain)
                            .frame(width: 20, height: 22)
                            .foregroundStyle(.black)
                            .background(.clear)
                            .font(.custom("Arial", size: 16).weight(.bold))
                            TextField("", value: mercuryShopViewModel.bindQuantityInShoppingCart(shopUIState: shopUIState), format: .number)
                                .keyboardType(.decimalPad)
                                .frame(width: 20, height: 22)
                            Button("+", action: { mercuryShopViewModel.increaseQuantityInShoppingCart(shopUIState: shopUIState) })
                            .buttonStyle(.plain)
                            .frame(width: 20, height: 22)
                            .foregroundStyle(.black)
                            .background(.clear)
                            .font(.custom("Arial", size: 16).weight(.bold))
                            Button(action: { mercuryShopViewModel.addToShoppingCartOrUpdateQuantity(shopUIState: shopUIState) }) {
                                Text(shopUIState.inStock ? "Добавить в корзину" : "Нет в наличии")
                            }
                            .buttonStyle(.plain)
                            .frame(width: screenWidth / 8, height: 22)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 5)
                            .foregroundStyle(.white)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color(.main)))
                            .opacity(shopUIState.inStock ? 1 : 0.5)
                            .font(.custom("Arial", size: 16).weight(.bold))
                        }
                        .overlay(Rectangle().stroke(.black, lineWidth: 2))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .scrollIndicators(.automatic, axes: .horizontal)
        .scrollIndicators(.automatic, axes: .vertical)
    }
}
