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
}

@Observable
final class MercuryShopViewModel {
    private var mercuryShopInteractor : MercuryShopInteractor
    var shopUIStates : [MercuryShopUIState] = []
    var cartUIStates : [MercuryShopUIState] = []
    var orderUIStates : [OrderUIState] = []
    //var allOrderItemUIStates : [OrderItemUIState] = []
    var orderItemUIStates : [OrderItemUIState] = []
    var taskObserveShopUIStates = Task<Void, Never>? = nil
    var taskObserveCartUIStates = Task<Void, Never>? = nil
    var taskObserveOrderUIStates = Task<Void, Never>? = nil
    var taskObserveOrderItemUIStates = Task<Void, Never>? = nil
    var navigationPath : [AppScreens] = []
    var currentScreen : AppScreens = AppScreens.main
    var currentOrderId : Int = 0
    var isMenuOpen : Bool = false
    var isShoppingCartOpen : Bool = false
    var isOrderListOpen : Bool = false
    var isOrderItemsOpen : Bool = false
    var currentOrder : OrderUIState {
        get { return orderUIStates.first { $0.id == currentOrderId } }
    }
    var isOrderOpen : Bool {
        get { return currentOrderId != null }
    }
    init() {
        let koinHelper : KoinHelper = KoinHelper()
        mercuryShopInteractor = koinHelper.getMercuryShopInteractor()
    }
    func observeShopUIStates() {
        taskObserveShopUIStates = Task { @MainActor in
            for await curShopUIStates in mercuryShopInteractor.shopUIStates {
                await MainActor.run {
                    shopUIStates = curShopUIStates
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
                await MainActor.run {
                    orderUIStates = curOrderUIStates
                }
            }
        }
    }
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
    func increaseEnteredQuantity(shopUIState: MercuryShopUIState) {
        mercuryShopInteractor.stepEnteredQuantity(shopUIState: shopUIState, decrease: false)
    }
    func decreaseEnteredQuantity(shopUIState: MercuryShopUIState) {
        mercuryShopInteractor.stepEnteredQuantity(shopUIState: shopUIState, decrease: true)
    }
    func bindEnteredQuantity(shopUIState: MercuryShopUIState) -> Binding<Float> {
        return Binding(
            get: {
                shopUIState.enteredQuantity
            },
            set: { newValue in
                self.mercuryShopInteractor.updateEnteredQuantity(shopUIState: shopUIState, quantity: newValue)
            }
        )
    }
    func addToShoppingCart(shopUIState : MercuryShopUIState) {
        Task {
            try? await mercuryShopInteractor.addToShoppingCart(shopUIState: shopUIState)
        }
    }
    func increaseShoppingCartQuantity(cartUIState : MercuryShopUIState) {
        Task {
            try? await mercuryShopInteractor.stepShoppingCartQuantity(cartUIState : cartUIState, decrease: false)
        }
    }
    func decreaseShoppingCartQuantity(cartUIState : MercuryShopUIState) {
        Task {
            try? await mercuryShopInteractor.stepShoppingCartQuantity(cartUIState : cartUIState, decrease: true)
        }
    }
    func bindShoppingCartQuantity(cartUIState : MercuryShopUIState) -> Binding<Float> {
        return Binding(
            get: {
                cartUIState.cartQuantity
            },
            set: { newValue in
                self.mercuryShopInteractor.updateEnteredQuantity(shopUIState: cartUIState, quantity: newValue)
            }
        )
    }
    func createOrder() {
        Task {
            try? currentOrderId = await mercuryShopInteractor.createOrder()
        }
    }
    func updateOrderProperty(
        id : Int32 = 0,
        amount : Float = 0.0,
        clientName : String = "",
        clientContacts : [shared.ContactType : String] = [ : ],
        creationDate : Date = Date(),
        completionDate : Date = Date(),
        status : shared.OrderStatus = .none) {
         Task {
            try? await mercuryShopInteractor.updateOrderProperty(
                id : id,
                amount : amount,
                clientName : clientName,
                clientContacts : clientContacts,
                creationDate : creationDate.toLocalDateTime(),
                completionDate : completionDate.toLocalDateTime(),
                status : status)
         }
    }
    func bindOrderClientName() -> Binding<String> {
        return Binding(
            get: {
                self.currentOrder.clientName
            },
            set: { newValue in
                self.updateOrderProperty(id: self.currentOrderId, clientName: newValue)
            }
        )
    }
    func bindOrderAmount() -> Binding<Float> {
        return Binding(
            get: {
                self.currentOrder.amount
            },
            set: { newValue in
                self.updateOrderProperty(id: self.currentOrderId, amount: newValue)
            }
        )
    }
    func bindOrderStatus() -> Binding<String> {
        return Binding(
            get: {
                self.currentOrder.status.label
            },
            set: { newValue in
                let orderStatus : OrderStatus = OrderStatus.Companion().fromLabel(label: newValue)
                self.updateOrderProperty(id: self.currentOrderId, status: orderStatus)
            }
        )
    }
}
