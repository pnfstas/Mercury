//
//  MainView.swift
//  iosApp
//
//  Created by Panferov Stanislav on 13.08.2026.
//

import SwiftUI
import shared

struct ProductCard : View {
    @Binding var product : ProductEntity
    var body: some View {
        HStack(alignment: .center, spacing: 5) {
            Image(product.image)
                .resizable()
                .renderingMode(.template)
                .frame(width: 150, height: 150)
                .scaledToFit()
                .background(.clear)
        }
    }
}

struct CatalogView: View {
    @Binding var productsViewModel : ProductsViewModel
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 7) {
                ForEach(productsViewModel.products, id: \.id) { product in
                    HStack(alignment: .center, spacing: 5) {
                        Image(product.image)
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 150, height: 150)
                            .scaledToFit()
                            .background(.clear)
                        VStack(alignment: .center, spacing: 10) {
                            Text(product.title)
                            Text(product.descr)
                        }
                        Text(String(product.price))
                            .frame(width: 150)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}
