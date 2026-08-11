import SwiftUI
import shared

@Observable
final class ProductsViewModel {
    private let productsInteractor : ProductsInteractor?
    init() {
        productsInteractor = ProductsModuleKt.getProductsInteractor()
    }
}
