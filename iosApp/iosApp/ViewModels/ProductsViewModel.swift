import SwiftUI
import shared

@Observable
final class ProductsViewModel {
    var products : [ProductEntity] = []
    init() {
        let koinHelper : KoinHelper = KoinHelper()
        let productsInteractor : ProductsInteractor = koinHelper.getProductsInteractor()
        Task {
            for await productEntities in productsInteractor.products {
                await MainActor.run {
                    products = productEntities
                }
            }
        }
    }
}
