//
//  DialogButtonStyle.swift
//  iosApp
//
//  Created by Panferov Stanislav on 08.11.2026.
//

import SwiftUI

struct DialogButtonStyle : ButtonStyle {
    var action : () -> Void
    var image: String? = nil
    var systemImage : String? = nil
    var width : CGFloat = 15.0
    var height : CGFloat = 22.0
    var padding : CGFloat = 4.0
    func makeBody(configuration: Configuration) -> some View {
    }
}
