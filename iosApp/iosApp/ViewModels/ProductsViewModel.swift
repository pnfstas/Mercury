import SwiftUI
import shared

@Observable
final class ProductsViewModel {
    var products : [ProductEntity] = []
    init() {
        let koinHelper : KoinHelper = KoinHelper()
        let productsInteractor : ProductsInteractor = koinHelper.getProductsInteractor()
        Task {
            for await productEnties in productsInteractor.products {
                await MainActor.run {
                    products = productEnties
                }
            }
        }
    }
}
