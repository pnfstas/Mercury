//
//  MainView.swift
//  iosApp
//
//  Created by Panferov Stanislav on 13.08.2026.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        VStack {
            Text("Главная")
                .background(Image("MainBackground"))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Image("MainBackground"))
    }
}
