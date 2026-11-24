//
//  MercuryShopViewModel.swift
//  iosApp
//
//  Created by Panferov Stanislav on 03.08.2026.
//
import SwiftUI
import shared

enum AppScreens : Hashable, CaseIterable {
    case main
    case catalog
    case favorites
    case shoppingCart
    case orders
    case about
    case contacts
    case questions
    var description : String {
        return switch self {
        case .main: "Главная"
        case .catalog: "Каталог"
        case .favorites: "Избранное"
        case .shoppingCart: "Корзина"
        case .orders: "Заказы"
        case .about: "Об организации"
        case .contacts: "Контакты"
        case .questions: "Частые вопросы"
        }
    }
    var buttonImageName : String {
        return switch self {
        case .catalog: "Catalog"
        case .favorites: "Favorites"
        case .shoppingCart: "ShoppingCart"
        case .orders: "OrderList"
        default: ""
        }
    }
    var buttonBackgroundColor : Color {
        return switch self {
        case .catalog: .main
        default: .clear
        }
    }
    var buttonForegroundColor : Color {
        return switch self {
        case .catalog: Color.white
        default: Color.black
        }
    }
 }

extension Date {
    private static let defaultDateFormatter : DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        return dateFormatter
    }()
    func toLocalDateTime() -> Kotlinx_datetimeLocalDateTime {
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond], from: self)
        let year : Int32 = Int32(components.year ?? 1970)
        let month : Int32 = Int32(components.month ?? 1)
        let day : Int32 = Int32(components.day ?? 1)
        let hour : Int32 = Int32(components.hour ?? 0)
        let minute : Int32 = Int32(components.minute ?? 0)
        let second : Int32 = Int32(components.second ?? 0)
        let nanosecond : Int32 = Int32(components.nanosecond ?? 0)
        return Kotlinx_datetimeLocalDateTime(
            year: year,
            month: month,
            day: day,
            hour: hour,
            minute: minute,
            second: second,
            nanosecond: nanosecond)
    }
    func toString() -> String {
        return Self.defaultDateFormatter.string(from: self)
    }
}
extension Kotlinx_datetimeLocalDateTime {
    func toDate() -> Date {
        let calendar : Calendar = Calendar.current
        let year : Int = Int(self.year)
        let month : Int = Int(self.month.ordinal) + 1
        let day : Int = Int(self.day)
        let hour : Int = Int(self.hour)
        let minute : Int = Int(self.minute)
        let second : Int = Int(self.second)
        let nanosecond : Int = Int(self.nanosecond)
        let components : DateComponents = DateComponents(
            calendar: calendar,
            year: year,
            month: month,
            day: day,
            hour: hour,
            minute: minute,
            second: second,
            nanosecond: nanosecond
        )
        return Calendar.current.date(from: components) ?? Date()
    }
    func toFormattedString() -> String {
        return self.toDate().toString()
    }
}

extension OrderUIState {
    func `with`(
        id : Int32? = nil,
        amount : Float? = nil,
        clientName : String? = nil,
        clientContacts : [ContactType : String]? = nil,
        creationDate : Kotlinx_datetimeLocalDateTime? = nil,
        completionDate : Kotlinx_datetimeLocalDateTime? = nil,
        status : OrderStatus? = nil,
        items : [OrderItemUIState]? = nil) -> OrderUIState {
            return self.doCopy(
                id: id ?? self.id,
                amount: amount ?? self.amount,
                clientName: clientName ?? self.clientName,
                clientContacts: clientContacts ?? self.clientContacts,
                creationDate: creationDate ?? self.creationDate,
                completionDate: completionDate ?? self.completionDate,
                status: status ?? self.status,
                items : items ?? self.items)
        }
}

typealias ProductUIStateTuple = (productId : Int, uiState : ProductUIState)

@Observable
final class MercuryShopViewModel {
    let defaultDateStr : String = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        return dateFormatter
    }().string(from: Date())
    private var mercuryShopInteractor : MercuryShopInteractor
    var productUIStates : [ProductUIStateTuple] = []
    var cartUIStates : [ShoppingCartUIState] = []
    var orderUIStates : [OrderUIState] = []
    //var orderItemUIStates : [OrderItemUIState] = []
    var taskObserveProductUIStates : Task<Void, Never>? = nil
    var taskObserveCartUIStates : Task<Void, Never>? = nil
    var taskObserveOrderUIStates : Task<Void, Never>? = nil
    //var taskObserveOrderItemUIStates : Task<Void, Never>? = nil
    var navigationPath : [AppScreens] = []
    var currentScreen : AppScreens = AppScreens.main
    var currentOrder : OrderUIState? = nil
    var selectedOrder : OrderUIState? = nil
    var selectedOrderItem : OrderItemUIState? = nil
    var isMenuOpen : Bool = false
    var isShoppingCartOpen : Bool = false
    var isOrderListOpen : Bool = false
    var isOrderItemsOpen : Bool = false
    var isOrderOpen : Bool {
        get { return currentOrder != nil }
    }
    var cancelOrderOpacity : CGFloat {
        get { return if let selectedOrder, selectedOrder.status.name == OrderStatus.created.name  { 1 } else { 0.5 } }
    }
    var deleteOrderOpacity : CGFloat {
        get { return selectedOrder != nil ? 1 : 0.5 }
    }
    var deleteAllOrdersOpacity : CGFloat {
        get { return !orderUIStates.isEmpty ? 1 : 0.5 }
    }
    var deleteItemOfCurrentOrderOpacity : CGFloat {
        get { return currentOrder != nil && selectedOrderItem != nil ? 1 : 0.5 }
    }
    var deleteAllItemsOfCurrentOrderOpacity : CGFloat {
        get { return if let currentOrder, currentOrder.items.count > 0 { 1 } else { 0.5 } }
    }
    init() {
        let koinHelper : KoinHelper = KoinHelper()
        mercuryShopInteractor = koinHelper.getMercuryShopInteractor()
    }
    func observeProductUIStates() {
        taskObserveProductUIStates = Task { @MainActor in
            for await curProductUIStates in mercuryShopInteractor.productUIStates {
                let nsDictionary : NSDictionary = curProductUIStates as NSDictionary
                await MainActor.run {
                    productUIStates = nsDictionary.compactMap { key, value -> ProductUIStateTuple? in
                        if let numberKey = key as? NSNumber, let state = value as? ProductUIState { (productId: numberKey.intValue, uiState: state) }
                        else { nil } }.sorted { $0.uiState.elite && !$1.uiState.elite } // && $0.productId < $1.productId }
                }
            }
        }
    }
    func observeCartUIStates() {
        taskObserveCartUIStates = Task { @MainActor in
            for await curCartUIStates in mercuryShopInteractor.cartUIStates {
                await MainActor.run {
                    cartUIStates = curCartUIStates
                }
            }
        }
    }
    func observeOrderUIStates() {
        taskObserveOrderUIStates = Task { @MainActor in
            for await curOrderUIStates in mercuryShopInteractor.orderUIStates {
                orderUIStates = curOrderUIStates.compactMap { $0 as? OrderUIState }
                //orderUIStates = curOrderUIStates.compactMap { $0 as OrderUIState }
                if let selectedOrder {
                    self.selectedOrder = orderUIStates.first(where: { $0.id == selectedOrder.id }) ?? orderUIStates.first
                }
                else {
                    self.selectedOrder = orderUIStates.first
                }
            }
        }
    }
    /*
    func observeOrderItemUIStates(orderUIState: OrderUIState) {
        taskObserveOrderItemUIStates = Task { @MainActor in
            let stateFlowOrderItemUIStates = mercuryShopInteractor.getOrderItemUIStates(orderUIState: orderUIState)
            for await curOrderItemUIStates in stateFlowOrderItemUIStates {
                await MainActor.run {
                    orderItemUIStates = curOrderItemUIStates
                }
            }
        }
    }
    */
    func updateSelectedOrder(_ selectedOrder: OrderUIState?) {
        if let selectedOrder {
            self.selectedOrder = orderUIStates.first(where: { $0.id == selectedOrder.id }) ?? orderUIStates.first
        }
        else {
            self.selectedOrder = orderUIStates.first
        }
    }
    func updateSelectedOrderItem(_ selectedOrderItem: OrderItemUIState?) {
        if let selectedOrderItem {
            self.selectedOrderItem = orderUIStates.lazy.flatMap { $0.items }
                .first { $0.orderId == selectedOrderItem.orderId && $0.productId == selectedOrderItem.productId }
        }
        if self.selectedOrderItem == nil, let currentOrder {
            self.selectedOrderItem = orderUIStates.lazy.flatMap { $0.items }
                .first { $0.orderId == currentOrder.id }
        }
    }
    func increaseEnteredQuantity(productUIState: ProductUIState) {
        mercuryShopInteractor.stepEnteredQuantity(productUIState: productUIState, decrease: false)
    }
    func decreaseEnteredQuantity(productUIState: ProductUIState) {
        mercuryShopInteractor.stepEnteredQuantity(productUIState: productUIState, decrease: true)
    }
    func bindEnteredQuantity(productUIState: ProductUIState) -> Binding<Float> {
        return Binding(
            get: {
                productUIState.enteredQuantity
            },
            set: { newValue in
                self.mercuryShopInteractor.updateEnteredQuantity(productId: productUIState.id, quantity: newValue)
            }
        )
    }
    func addToShoppingCart(productUIState: ProductUIState) {
        Task {
            try? await mercuryShopInteractor.addToShoppingCart(productUIState: productUIState)
        }
    }
    func clearShoppingCart() {
        Task {
            try? await mercuryShopInteractor.clearShoppingCart()
        }
    }
    func increaseShoppingCartQuantity(_ cartUIState : ShoppingCartUIState) {
        Task {
            try? await mercuryShopInteractor.stepShoppingCartQuantity(cartUIState : cartUIState, decrease: false)
        }
    }
    func decreaseShoppingCartQuantity(_ cartUIState : ShoppingCartUIState) {
        Task {
            try? await mercuryShopInteractor.stepShoppingCartQuantity(cartUIState : cartUIState, decrease: true)
        }
    }
    func bindShoppingCartQuantity(_ cartUIState : ShoppingCartUIState) -> Binding<Float> {
        return Binding(
            get: {
                cartUIState.quantity
            },
            set: { newValue in
                self.mercuryShopInteractor.updateEnteredQuantity(productId: cartUIState.productId, quantity: newValue)
            }
        )
    }
    func createOrder() {
        Task {
            currentOrder = try? await mercuryShopInteractor.createOrder()
        }
    }
    func saveOrder(_ close : Bool = false) {
        Task {
            _ = try? await mercuryShopInteractor.saveOrder(orderUIState : self.currentOrder)
            if close {
                currentOrder = nil
            }
        }
    }
    func cancelOrder() {
        Task {
            if let orderUIState = selectedOrder  {
                _ = try? await mercuryShopInteractor.cancelOrder(orderUIState : orderUIState)
            }
        }
    }
    func deleteOrder() {
        Task {
            if let selectedOrder  {
                let orderId = selectedOrder.id
                if let count = try? await mercuryShopInteractor.deleteOrder(orderUIState : selectedOrder), Int(truncating : count) > 0 {
                    if let currentOrder, currentOrder.id == orderId {
                        self.currentOrder = nil
                    }
                    updateSelectedOrder(selectedOrder)
                }
            }
        }
    }
    func deleteAllOrders() {
        Task {
            if let count = try? await mercuryShopInteractor.deleteAllOrders(), Int(truncating : count) > 0 {
                currentOrder = nil
                selectedOrder = nil
            }
        }
    }
    func bindOrderClientName() -> Binding<String> {
        return Binding(
            get: {
                self.currentOrder?.clientName ?? ""
            },
            set: { newValue in
                self.currentOrder = self.currentOrder?.with(clientName: newValue)
            }
        )
    }
    func bindOrderAmount() -> Binding<Float> {
        return Binding(
            get: {
                self.currentOrder?.amount ?? 0.0
            },
            set: { newValue in
                self.currentOrder = self.currentOrder?.with(amount: newValue)
            }
        )
    }
    func bindOrderStatus() -> Binding<OrderStatus> {
        return Binding(
            get: {
                self.currentOrder?.status ?? .none
            },
            set: { newValue in
                //let orderStatus : OrderStatus = OrderStatus.Companion().fromLabel(label: newValue)
                self.currentOrder = self.currentOrder?.with(status: newValue)
            }
        )
    }
    func increaseOrderItemQuantity(_ orderItemUIState : OrderItemUIState) {
        Task {
            try? await mercuryShopInteractor.stepOrderItemQuantity(orderItemUIState : orderItemUIState, decrease: false)
        }
    }
    func decreaseOrderItemQuantity(_ orderItemUIState : OrderItemUIState) {
        Task {
            try? await mercuryShopInteractor.stepOrderItemQuantity(orderItemUIState : orderItemUIState, decrease: true)
        }
    }
    func bindOrderItemQuantity(_ orderItemUIState : OrderItemUIState) -> Binding<Float> {
        return Binding(
            get: {
                orderItemUIState.quantity
            },
            set: { newValue in
                self.mercuryShopInteractor.updateEnteredQuantity(productId: orderItemUIState.productId, quantity: newValue)
            }
        )
    }
    func deleteItemOfCurrentOrder() {
        Task {
            if let currentOrder, let selectedOrderItem {
                if let count = try? await mercuryShopInteractor.deleteOrderItem(orderItemUIState : selectedOrderItem), Int(truncating : count) > 0 {
                    updateSelectedOrderItem(selectedOrderItem)
                }
            }
        }
    }
    func deleteAllItemsOfCurrentOrder() {
        Task {
            if let currentOrder {
                if let count = try? await mercuryShopInteractor.deleteAllItemsOfOrder(orderUIState : currentOrder), Int(truncating : count) > 0 {
                    self.selectedOrderItem = nil
                }
            }
        }
    }

}
