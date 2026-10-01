import Foundation
import WidgetKit
import React

@objc(ZeniusWidgetBridge)
class ZeniusWidgetBridge: NSObject {

  @objc
  static func requiresMainQueueSetup() -> Bool {
    return false
  }

  @objc
  func updateWidgetData(
    _ data: NSDictionary,
    resolve: @escaping RCTPromiseResolveBlock,
    reject: @escaping RCTPromiseRejectBlock
  ) {
    let defaults = UserDefaults(suiteName: "group.com.zenius.app")

    if let streak = data["streakDays"] as? Int {
      defaults?.set(streak, forKey: "streakDays")
    }
    if let subject = data["currentSubject"] as? String {
      defaults?.set(subject, forKey: "currentSubject")
    }
    if let progress = data["progressPercent"] as? Int {
      defaults?.set(progress, forKey: "progressPercent")
    }
    if let nextClass = data["nextClassTime"] as? String {
      defaults?.set(nextClass, forKey: "nextClassTime")
    }
    if let quote = data["quote"] as? String {
      defaults?.set(quote, forKey: "quote")
    }

    defaults?.synchronize()

    if #available(iOS 14.0, *) {
      WidgetCenter.shared.reloadAllTimelines()
    }

    resolve(true)
  }

  @objc
  func reloadWidget(
    _ resolve: @escaping RCTPromiseResolveBlock,
    reject: @escaping RCTPromiseRejectBlock
  ) {
    if #available(iOS 14.0, *) {
      WidgetCenter.shared.reloadAllTimelines()
    }
    resolve(true)
  }
}
