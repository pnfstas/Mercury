import SwiftUI
import shared

@Observable
final class ProductsViewModel {
    var products : [ProductEntity] = []
    init() {
        let productsInteractor : ProductsInteractor = //ProductsModuleKt.getProductsInteractor()
        Task {
            for await productEnties in productsInteractor.products {
                await MainActor.run {
                    products = productEnties
                }
            }
        }
    }
}
