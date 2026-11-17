//
//  Catalog.swift
//  iosApp
//
//  Created by Panferov Stanislav on 13.08.2026.
//

import SwiftUI
import shared

struct CatalogView: View {
    var viewModel : MercuryShopViewModel
    @Environment(\.screenSize) private var screenSize
    var body: some View {
        //@Bindable var viewModel : MercuryShopViewModel = mercuryViewModel
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 7) {
                ForEach(viewModel.productUIStates, id: \.productId) { element in
                    HStack(alignment: .center, spacing: 2) {
                        AsyncImage(url: URL(string: element.uiState.image)) { image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                            .frame(width: screenSize.width / 8, height: screenSize.width / 8)
                         VStack(alignment: .center, spacing: 10) {
                             Text(element.uiState.title)
                             Text(element.uiState.descr)
                        }
                            .frame(maxWidth: .infinity)
                        Text(element.uiState.priceDescr)
                            .frame(width: screenSize.width / 8)
                        HStack {
                            IconButton(action: { viewModel.decreaseEnteredQuantity(productUIState: element.uiState) }, systemImage: "minus")
                            TextField("", value: viewModel.bindEnteredQuantity(productUIState: element.uiState), format: .number)
                                .keyboardType(.decimalPad)
                                .frame(width: 20, height: 22)
                            IconButton(action: { viewModel.increaseEnteredQuantity(productUIState: element.uiState) }, systemImage: "plus")
                        }
                        .overlay(Rectangle().stroke(.black, lineWidth: 2))
                        Button(action: { viewModel.addToShoppingCart(productUIState: element.uiState) }) {
                            Text(element.uiState.inStock ? "Добавить в корзину" : "Нет в наличии")
                        }
                        .buttonStyle(.plain)
                        .frame(width: screenSize.width / 4, height: 40)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 5)
                        .foregroundStyle(.white)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color(.main)))
                        .opacity(element.uiState.inStock ? 1 : 0.5)
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
