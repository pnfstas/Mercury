//
//  MainView.swift
//  iosApp
//
//  Created by Panferov Stanislav on 13.08.2026.
//

import SwiftUI

struct ProductCard : View {
    var body: some View {
        HStack(alignment: .center, spacing: 5) {
            Image
        }
    }
}

struct CatalogView: View {
    @Binding var productsViewModel : ProductsViewModel
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 7) {
                ForEach(productsViewModel.products, id: \.name) { product in
                    HStack(alignment: .center, spacing: 5) {
                        Image(product.picture)
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 150, height: 150)
                            .scaledToFit()
                            .background(Color.clear)
                    }
                }
            }
        }
    }
}
