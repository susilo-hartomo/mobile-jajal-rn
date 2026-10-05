//
//  ZeniusWidget.swift
//  ZeniusWidget
//

import WidgetKit
import SwiftUI

private enum WidgetStore {
    static let groupID = "group.com.zenius.app"
    static let kind = "ZeniusWidget"

    static var defaults: UserDefaults? { UserDefaults(suiteName: groupID) }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let streakDays: Int
    let activeSubject: String
    let dailyProgress: Double
    let minutesLearned: Int
    let pokemonName: String
    let pokemonImageData: Data?
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), streakDays: 5, activeSubject: "Matematika",
                    dailyProgress: 0.6, minutesLearned: 30,
                    pokemonName: "pikachu", pokemonImageData: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        // Return instantly for widget gallery and home screen drop animation
        completion(fetchCachedEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        Task {
            var entry = fetchCachedEntry()

            // Poll a new random Pokemon from PokeAPI GraphQL
            if let random = await ZeniusWidgetClient.fetchRandomPokemon(),
               let data = await ZeniusWidgetClient.downloadImageData(from: random.imageURL) {
                WidgetStore.defaults?.set(data, forKey: "pokemonImageData")
                WidgetStore.defaults?.set(random.name, forKey: "pokemonImageName")
                WidgetStore.defaults?.set(random.name, forKey: "pokemonAvatar")
                WidgetStore.defaults?.synchronize()

                entry = SimpleEntry(
                    date: Date(),
                    streakDays: entry.streakDays,
                    activeSubject: entry.activeSubject,
                    dailyProgress: entry.dailyProgress,
                    minutesLearned: entry.minutesLearned,
                    pokemonName: random.name,
                    pokemonImageData: data
                )
            } else if entry.pokemonImageData == nil,
                      let spriteURL = await ZeniusWidgetClient.fetchSpriteURL(name: entry.pokemonName),
                      let data = await ZeniusWidgetClient.downloadImageData(from: spriteURL) {
                WidgetStore.defaults?.set(data, forKey: "pokemonImageData")
                WidgetStore.defaults?.set(entry.pokemonName, forKey: "pokemonImageName")
                WidgetStore.defaults?.synchronize()

                entry = SimpleEntry(
                    date: Date(),
                    streakDays: entry.streakDays,
                    activeSubject: entry.activeSubject,
                    dailyProgress: entry.dailyProgress,
                    minutesLearned: entry.minutesLearned,
                    pokemonName: entry.pokemonName,
                    pokemonImageData: data
                )
            }

            // Schedule the next update after 1 minute (60 seconds)
            let nextUpdate = Date().addingTimeInterval(60)
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }

    private func fetchCachedEntry() -> SimpleEntry {
        let userDefaults = WidgetStore.defaults
        let streak = (userDefaults?.object(forKey: "streakDays") as? Int) ?? 5
        let subject = userDefaults?.string(forKey: "activeSubject") ?? "Matematika"
        let progress = (userDefaults?.object(forKey: "dailyProgress") as? Double) ?? 0.6
        let minutes = (userDefaults?.object(forKey: "minutesLearned") as? Int) ?? 30
        let pokemonName = userDefaults?.string(forKey: "pokemonAvatar") ?? "pikachu"
        let savedImageData = userDefaults?.string(forKey: "pokemonImageName") == pokemonName
            ? userDefaults?.data(forKey: "pokemonImageData") : nil

        return SimpleEntry(
            date: Date(),
            streakDays: max(0, streak),
            activeSubject: subject.isEmpty ? "Matematika" : subject,
            dailyProgress: progress.isFinite ? min(max(progress, 0), 1) : 0,
            minutesLearned: max(0, minutes),
            pokemonName: pokemonName,
            pokemonImageData: savedImageData
        )
    }

}

extension View {
    @ViewBuilder
    func widgetBackground(_ backgroundView: some View) -> some View {
        if #available(iOS 17.0, *) {
            containerBackground(for: .widget) {
                backgroundView
            }
        } else {
            background(backgroundView)
        }
    }
}

struct PokemonAvatarView: View {
    let imageData: Data?
    var size: CGFloat = 60

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.purple.opacity(0.18))
                .frame(width: size + 8, height: size + 8)
                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)

            if let data = imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .interpolation(.none)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size, height: size)
            } else {
                Text("⚡️")
                    .font(.system(size: size * 0.55))
            }
        }
    }
}

struct ZeniusWidgetEntryView : View {
    var entry: Provider.Entry
    @SwiftUI.Environment(\.widgetFamily) var family

    private var pokemonOverlaySize: CGFloat {
        switch family {
        case .systemSmall:
            return 40
        case .systemMedium:
            return 52
        default:
            return 72
        }
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Layer 1 (Base Content)
            Group {
                switch family {
                case .systemSmall:
                    smallWidgetView
                case .systemMedium:
                    mediumWidgetView
                default:
                    largeWidgetView
                }
            }

            // Layer 2 (Z-Index Top Overlay): Gambar Pokemon Besar di Pojok Kanan Bawah
            PokemonAvatarView(imageData: entry.pokemonImageData, size: pokemonOverlaySize)
                .padding(6)
                .zIndex(999)
        }
    }

    // MARK: - Small Widget
    var smallWidgetView: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: "book.fill")
                    .foregroundColor(.purple)
                    .font(.caption)
                Text("Zenius")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.purple)
                Spacer()
                Text("🔥 \(entry.streakDays)d")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
            }

            Spacer()

            Text(entry.activeSubject)
                .font(.subheadline)
                .fontWeight(.bold)
                .lineLimit(1)
                .padding(.trailing, 28)

            ProgressView(value: entry.dailyProgress)
                .tint(.purple)
                .padding(.trailing, 28)

            Text("\(Int(entry.dailyProgress * 100))% Selesai")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .widgetBackground(Color(UIColor.systemBackground))
    }

    // MARK: - Medium Widget
    var mediumWidgetView: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .foregroundColor(.purple)
                        .font(.caption)
                    Text("ZENIUS LEARN")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.purple)
                    Text("• \(entry.pokemonName.capitalized)")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.secondary)
                }

                Text(entry.activeSubject)
                    .font(.title3)
                    .fontWeight(.bold)

                Text("Target Harian: \(entry.minutesLearned) Menit")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                ProgressView(value: entry.dailyProgress)
                    .tint(.purple)
                    .padding(.trailing, 45)
            }

            Divider()

            VStack(alignment: .trailing, spacing: 6) {
                HStack(spacing: 4) {
                    Text("🔥 \(entry.streakDays)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    Text("Hari")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                HStack(spacing: 4) {
                    Text("⏱️ \(entry.minutesLearned)m")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }

                Spacer()
            }
            .frame(width: 75, alignment: .topTrailing)
        }
        .padding()
        .widgetBackground(Color(UIColor.systemBackground))
    }

    // MARK: - Large Widget
    var largeWidgetView: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "graduationcap.fill")
                    .foregroundColor(.purple)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Zenius Education")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                    Text("Ringkasan Belajar")
                        .font(.headline)
                        .fontWeight(.bold)
                }
                Spacer()
                Text("🔥 \(entry.streakDays) Hari")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.15))
                    .foregroundColor(.orange)
                    .cornerRadius(10)
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("Materi Aktif Saat Ini")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(entry.activeSubject)
                    .font(.headline)
                    .fontWeight(.semibold)

                ProgressView(value: entry.dailyProgress)
                    .tint(.purple)
                HStack {
                    Text("Progress: \(Int(entry.dailyProgress * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("Waktu: \(entry.minutesLearned) Min")
                        .font(.caption)
                        .foregroundColor(.purple)
                        .fontWeight(.bold)
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)

            Spacer()

            HStack(spacing: 12) {
                WidgetStatCard(title: "Fisika", value: "85%", icon: "atom")
                WidgetStatCard(title: "Biologi", value: "90%", icon: "leaf.fill")
                WidgetStatCard(title: "Kimia", value: "70%", icon: "flask.fill")
            }
        }
        .padding()
        .widgetBackground(Color(UIColor.systemBackground))
    }
}

struct WidgetStatCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(.purple)
                .font(.caption)
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
}

struct ZeniusWidget: Widget {
    let kind: String = WidgetStore.kind

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ZeniusWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Zenius Widget")
        .description("Pantau streak belajar dan materi harian Zenius kamu.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

@main
struct ZeniusWidgetBundle: WidgetBundle {
    var body: some Widget {
        ZeniusWidget()
    }
}
