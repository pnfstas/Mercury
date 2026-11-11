//
//  Catalog.swift
//  iosApp
//
//  Created by Panferov Stanislav on 13.08.2026.
//

import SwiftUI
import shared

struct CatalogView: View {
    var mercuryViewModel : MercuryShopViewModel
    var body: some View {
        @Bindable var viewModel : MercuryShopViewModel = mercuryViewModel
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 7) {
                ForEach(viewModel.shopUIStates, id: \.product.id) { shopUIState in
                    HStack(alignment: .center, spacing: 2) {
                        AsyncImage(url: URL(string: shopUIState.product.image)) { image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                            .frame(width: screenWidthPortion(1 / 8), height: screenWidthPortion(1 / 8))
                         VStack(alignment: .center, spacing: 10) {
                            Text(shopUIState.product.title)
                            Text(shopUIState.product.descr)
                        }
                            .frame(maxWidth: .infinity)
                        Text(shopUIState.product.priceDescr)
                            .frame(width: screenWidthPortion(1 / 8))
                        HStack {
                            IconButton(action: { viewModel.decreaseEnteredQuantity(shopUIState: shopUIState) }, systemImage: "minus")
                            TextField("", value: viewModel.bindEnteredQuantity(shopUIState: shopUIState), format: .number)
                                .keyboardType(.decimalPad)
                                .frame(width: 20, height: 22)
                            IconButton(action: { viewModel.increaseEnteredQuantity(shopUIState: shopUIState) }, systemImage: "plus")
                        }
                        .overlay(Rectangle().stroke(.black, lineWidth: 2))
                        Button(action: { viewModel.addToShoppingCart(shopUIState: shopUIState) }) {
                            Text(shopUIState.inStock ? "Добавить в корзину" : "Нет в наличии")
                        }
                        .buttonStyle(.plain)
                        .frame(width: screenWidthPortion(1 / 4), height: 40)
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
