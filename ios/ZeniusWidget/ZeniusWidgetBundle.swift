//
//  ZeniusWidgetBundle.swift
//  ZeniusWidget
//

import WidgetKit
import SwiftUI

@main
struct ZeniusWidgetBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        ZeniusWidget()
        WidgetFcy()
    }
}
