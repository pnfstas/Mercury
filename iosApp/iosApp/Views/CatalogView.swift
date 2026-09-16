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
                ForEach(mercuryShopViewModel.shopUIStates, id: \.product.id) { shopUIState in
                    HStack(alignment: .center, spacing: 2) {
                        AsyncImage(url: URL(string: shopUIState.product.image)) { image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                            .frame(width: screenWidth / 8, height: screenWidth / 8)
                         VStack(alignment: .center, spacing: 10) {
                            Text(shopUIState.product.title)
                            Text(shopUIState.product.descr)
                        }
                            .frame(maxWidth: .infinity)
                        Text(shopUIState.product.priceDescr)
                            .frame(width: screenWidth / 8)
                        HStack {
                            IconButton(action: { mercuryShopViewModel.decreaseEnteredQuantity(shopUIState: shopUIState) }, systemImage: "minus")
                            TextField("", value: mercuryShopViewModel.bindEnteredQuantity(shopUIState: shopUIState), format: .number)
                                .keyboardType(.decimalPad)
                                .frame(width: 20, height: 22)
                            IconButton(action: { mercuryShopViewModel.increaseEnteredQuantity(shopUIState: shopUIState) }, systemImage: "plus")
                        }
                        .overlay(Rectangle().stroke(.black, lineWidth: 2))
                        Button(action: { mercuryShopViewModel.addToShoppingCart(shopUIState: shopUIState) }) {
                            Text(shopUIState.inStock ? "Добавить в корзину" : "Нет в наличии")
                        }
                        .buttonStyle(.plain)
                        .frame(width: screenWidth / 4, height: 40)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 5)
                        .foregroundStyle(.white)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color(.main)))
                        .opacity(shopUIState.inStock ? 1 : 0.5)
                        .font(.custom("Arial", size: 14).weight(.bold))
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
