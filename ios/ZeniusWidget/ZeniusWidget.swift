//
//  ZeniusWidget.swift
//  ZeniusWidget
//

import WidgetKit
import SwiftUI
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Konfigurasi Widget" }
    static var description: IntentDescription { "Widget Aktivitas Belajar Zenius" }

    @Parameter(title: "Emoji Favorit", default: "📚")
    var favoriteEmoji: String
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let streakDays: Int
    let activeSubject: String
    let dailyProgress: Double
    let minutesLearned: Int
}

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), streakDays: 7, activeSubject: "Matematika", dailyProgress: 0.75, minutesLearned: 45)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        fetchCurrentEntry()
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let entry = fetchCurrentEntry()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }

    private func fetchCurrentEntry() -> SimpleEntry {
        let userDefaults = UserDefaults(suiteName: "group.com.zenius.app")
        let streak = userDefaults?.integer(forKey: "streakDays") ?? 5
        let subject = userDefaults?.string(forKey: "activeSubject") ?? "Matematika"
        let progress = userDefaults?.double(forKey: "dailyProgress") ?? 0.6
        let minutes = userDefaults?.integer(forKey: "minutesLearned") ?? 30
        
        return SimpleEntry(
            date: Date(),
            streakDays: streak > 0 ? streak : 5,
            activeSubject: subject.isEmpty ? "Matematika" : subject,
            dailyProgress: progress > 0 ? progress : 0.6,
            minutesLearned: minutes > 0 ? minutes : 30
        )
    }
}

struct ZeniusWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            smallWidgetView
        case .systemMedium:
            mediumWidgetView
        default:
            largeWidgetView
        }
    }

    // MARK: - Small Widget
    var smallWidgetView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Zenius")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.purple)
                Spacer()
                Text("🔥 \(entry.streakDays) Hari")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
            }

            Spacer()

            Text(entry.activeSubject)
                .font(.subheadline)
                .fontWeight(.bold)
                .lineLimit(1)

            ProgressView(value: entry.dailyProgress)
                .tint(.purple)

            Text("\(Int(entry.dailyProgress * 100))% Selesai")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .containerBackground(for: .widget) {
            Color(UIColor.systemBackground)
        }
    }

    // MARK: - Medium Widget
    var mediumWidgetView: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Circle()
                        .fill(Color.purple)
                        .frame(width: 8, height: 8)
                    Text("ZENIUS LEARN")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
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
            }

            Divider()

            VStack(spacing: 12) {
                VStack(spacing: 2) {
                    Text("🔥 \(entry.streakDays)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    Text("Streak")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                VStack(spacing: 2) {
                    Text("⏱️ \(entry.minutesLearned)m")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Text("Belajar")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 80)
        }
        .padding()
        .containerBackground(for: .widget) {
            Color(UIColor.systemBackground)
        }
    }

    // MARK: - Large Widget
    var largeWidgetView: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Zenius Education")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                    Text("Ringkasan Belajar")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                Spacer()
                Text("🔥 \(entry.streakDays) Hari Streak")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.orange.opacity(0.15))
                    .foregroundColor(.orange)
                    .cornerRadius(12)
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
        .containerBackground(for: .widget) {
            Color(UIColor.systemBackground)
        }
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
    let kind: String = "ZeniusWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
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
