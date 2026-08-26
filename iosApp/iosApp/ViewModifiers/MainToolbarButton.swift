//
//  MainToolbarButton.swift
//  iosApp
//
//  Created by Panferov Stanislav on 18.08.2026.
//

import SwiftUI

struct MainToolbarButton : View {
    var appScreen : AppScreens? = nil
    var imageName : String? = nil
    var systemName : String? = nil
    var description : String? = nil
    var fgColor : Color? = nil
    var bkColor : Color? = nil
    var action : () -> Void
    var body : some View {
        Button(action: action) {
            let image : Image = systemName?.isEmpty == false ? Image(systemName: systemName ?? "") : Image(appScreen?.buttonImageName ?? imageName ?? "")
            image
                .resizable()
                .renderingMode(.template)
                .frame(width: 22, height: 22)
                .scaledToFit()
                .padding(.horizontal, 7)
                .padding(.vertical, 5)
                .foregroundStyle(appScreen?.buttonForegroundColor ?? fgColor ?? Color.black)
                .background(RoundedRectangle(cornerRadius: 8).fill(appScreen?.buttonBackgroundColor ?? bkColor ?? Color.clear))
        }
        .help(appScreen?.description ?? description ?? "")
        .buttonStyle(.plain)
    }
}
