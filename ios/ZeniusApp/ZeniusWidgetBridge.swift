import Foundation
import UIKit
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
    guard let defaults = UserDefaults(suiteName: "group.com.zenius.app") else {
      reject("WIDGET_APP_GROUP_UNAVAILABLE", "App Group widget tidak tersedia pada build ini.", nil)
      return
    }

    if let streak = data["streakDays"] as? NSNumber {
      defaults.set(max(0, streak.intValue), forKey: "streakDays")
    }
    if let subject = data["currentSubject"] as? String {
      defaults.set(subject, forKey: "activeSubject")
    }
    if let progress = data["progressPercent"] as? NSNumber, progress.doubleValue.isFinite {
      defaults.set(min(max(progress.doubleValue / 100, 0), 1), forKey: "dailyProgress")
    }
    if let minutes = data["minutesLearned"] as? NSNumber {
      defaults.set(max(0, minutes.intValue), forKey: "minutesLearned")
    }
    var pokemonToFetch: String? = nil
    if let avatar = data["pokemonAvatar"] as? String, !avatar.isEmpty {
      let lower = avatar.lowercased()
      defaults.set(lower, forKey: "pokemonAvatar")
      if defaults.string(forKey: "pokemonImageName") != lower || defaults.data(forKey: "pokemonImageData") == nil {
        pokemonToFetch = lower
      }
    }
    if let nextClass = data["nextClassTime"] as? String {
      defaults.set(nextClass, forKey: "nextClassTime")
    }
    if let quote = data["quote"] as? String {
      defaults.set(quote, forKey: "quote")
    }

    defaults.synchronize()

    if #available(iOS 14.0, *) {
      WidgetCenter.shared.reloadAllTimelines()
    }

    if let pokemonName = pokemonToFetch {
      Task {
        await Self.fetchAndCachePokemonSprite(name: pokemonName, defaults: defaults)
      }
    }

    resolve(true)
  }

  private static func fetchAndCachePokemonSprite(name: String, defaults: UserDefaults) async {
    let dataSource = PokemonNetworkDataSource()
    let result = await dataSource.fetchPokemon(name: name)
    switch result {
    case .success(let detail):
      guard let urlString = detail.sprites?.front_default,
            let url = URL(string: urlString) else { return }
      do {
        let (data, response) = try await URLSession.shared.data(from: url)
        if let http = response as? HTTPURLResponse, http.statusCode == 200, UIImage(data: data) != nil {
          defaults.set(data, forKey: "pokemonImageData")
          defaults.set(name, forKey: "pokemonImageName")
          defaults.synchronize()
          if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
          }
        }
      } catch {
        print("[ZeniusWidgetBridge] Sprite download failed: \(error)")
      }
    case .transportError(let err):
      print("[ZeniusWidgetBridge] Pokemon fetch transport error: \(err)")
    case .graphQLErrors(let errs):
      print("[ZeniusWidgetBridge] Pokemon fetch GraphQL errors: \(errs)")
    }
  }

  private static var pollingTask: Task<Void, Never>? = nil
  private static var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid

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

  @objc
  func startPokemonPolling(
    _ intervalSeconds: NSNumber,
    resolve: @escaping RCTPromiseResolveBlock,
    reject: @escaping RCTPromiseRejectBlock
  ) {
    let interval = max(intervalSeconds.doubleValue, 15.0)
    Self.stopPollingInternal()

    guard let defaults = UserDefaults(suiteName: "group.com.zenius.app") else {
      reject("APP_GROUP_UNAVAILABLE", "App Group unavailable", nil)
      return
    }

    Self.backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: "ZeniusPokemonWidgetPolling") {
      Self.stopPollingInternal()
    }

    Self.pollingTask = Task {
      while !Task.isCancelled {
        await Self.fetchRandomAndReload(defaults: defaults)
        do {
          try await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
        } catch {
          break
        }
      }
    }

    resolve(true)
  }

  @objc
  func stopPokemonPolling(
    _ resolve: @escaping RCTPromiseResolveBlock,
    reject: @escaping RCTPromiseRejectBlock
  ) {
    Self.stopPollingInternal()
    resolve(true)
  }

  @objc
  func rotateRandomPokemon(
    _ resolve: @escaping RCTPromiseResolveBlock,
    reject: @escaping RCTPromiseRejectBlock
  ) {
    guard let defaults = UserDefaults(suiteName: "group.com.zenius.app") else {
      reject("APP_GROUP_UNAVAILABLE", "App Group unavailable", nil)
      return
    }

    Task {
      let pokemonName = await Self.fetchRandomAndReload(defaults: defaults)
      resolve(pokemonName ?? "")
    }
  }

  private static func stopPollingInternal() {
    pollingTask?.cancel()
    pollingTask = nil
    if backgroundTaskID != .invalid {
      UIApplication.shared.endBackgroundTask(backgroundTaskID)
      backgroundTaskID = .invalid
    }
  }

  @discardableResult
  private static func fetchRandomAndReload(defaults: UserDefaults) async -> String? {
    let randomOffset = Int.random(in: 0...150)
    let dataSource = PokemonNetworkDataSource()
    let result = await dataSource.fetchPokemons(limit: 1, offset: randomOffset)
    guard case .success(let list) = result, let randomPoke = list.first else {
      return nil
    }

    guard let url = URL(string: randomPoke.image) else { return nil }
    do {
      let (data, response) = try await URLSession.shared.data(from: url)
      if let http = response as? HTTPURLResponse, http.statusCode == 200, UIImage(data: data) != nil {
        defaults.set(data, forKey: "pokemonImageData")
        defaults.set(randomPoke.name, forKey: "pokemonImageName")
        defaults.set(randomPoke.name, forKey: "pokemonAvatar")
        defaults.synchronize()

        if #available(iOS 14.0, *) {
          WidgetCenter.shared.reloadAllTimelines()
        }
        return randomPoke.name
      }
    } catch {
      print("[ZeniusWidgetBridge] Random sprite download error: \(error)")
    }
    return nil
  }
}
