//
//  ZeniusWidgetLiveActivity.swift
//  ZeniusWidget
//
//  Created by susilo hartomo on 01/10/26.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct ZeniusWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct ZeniusWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ZeniusWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension ZeniusWidgetAttributes {
    fileprivate static var preview: ZeniusWidgetAttributes {
        ZeniusWidgetAttributes(name: "World")
    }
}

extension ZeniusWidgetAttributes.ContentState {
    fileprivate static var smiley: ZeniusWidgetAttributes.ContentState {
        ZeniusWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: ZeniusWidgetAttributes.ContentState {
         ZeniusWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: ZeniusWidgetAttributes.preview) {
   ZeniusWidgetLiveActivity()
} contentStates: {
    ZeniusWidgetAttributes.ContentState.smiley
    ZeniusWidgetAttributes.ContentState.starEyes
}
