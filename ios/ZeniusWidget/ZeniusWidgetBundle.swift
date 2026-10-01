//
//  ZeniusWidgetBundle.swift
//  ZeniusWidget
//
//  Created by susilo hartomo on 01/10/26.
//

import WidgetKit
import SwiftUI

@main
struct ZeniusWidgetBundle: WidgetBundle {
    var body: some Widget {
        ZeniusWidget()
        ZeniusWidgetControl()
        ZeniusWidgetLiveActivity()
    }
}
