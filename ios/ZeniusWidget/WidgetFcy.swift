//
//  WidgetFcy.swift
//  ZeniusWidget
//

import WidgetKit
import SwiftUI

struct WidgetFcyEntry: TimelineEntry {
    let date: Date
    let fcyRates: [WidgetFcyModel]
}

enum CurrencyFormatter {
    static func format(_ value: String?) -> String {
        guard let raw = value, !raw.isEmpty else { return "-" }

        var cleaned = raw.replacingOccurrences(of: "Rp", with: "")
                         .trimmingCharacters(in: .whitespacesAndNewlines)

        while cleaned.hasSuffix(".") || cleaned.hasSuffix(",") {
            cleaned.removeLast()
        }

        if cleaned.isEmpty { return "-" }

        if cleaned.contains(",") && !cleaned.contains(".") {
            cleaned = cleaned.replacingOccurrences(of: ",", with: ".")
        }

        let integerPartString: String
        let fractionPartString: String?

        if let dotIndex = cleaned.firstIndex(of: ".") {
            integerPartString = String(cleaned[..<dotIndex])
            fractionPartString = String(cleaned[cleaned.index(after: dotIndex)...])
        } else {
            integerPartString = cleaned
            fractionPartString = nil
        }

        let formattedInteger: String
        if let doubleInt = Double(integerPartString) {
            let intFormatter = NumberFormatter()
            intFormatter.numberStyle = .decimal
            intFormatter.locale = Locale(identifier: "id_ID")
            intFormatter.maximumFractionDigits = 0
            formattedInteger = intFormatter.string(from: NSNumber(value: doubleInt)) ?? integerPartString
        } else {
            formattedInteger = integerPartString
        }

        if let fraction = fractionPartString, !fraction.isEmpty {
            let maxTwo = String(fraction.prefix(2))
            var trimmed = maxTwo
            while trimmed.hasSuffix("0") {
                trimmed.removeLast()
            }
            if !trimmed.isEmpty {
                return "Rp \(formattedInteger),\(trimmed)"
            }
        }

        return "Rp \(formattedInteger)"
    }
}

struct WidgetFcyProvider: TimelineProvider {
    func placeholder(in context: Context) -> WidgetFcyEntry {
        WidgetFcyEntry(
            date: Date(),
            fcyRates: [
                WidgetFcyModel(
                    id: "USD",
                    currency: "USD",
                    imageData: nil,
                    buyPrice: CurrencyFormatter.format("16078.0000000"),
                    sellPrice: CurrencyFormatter.format("16240.0000000"),
                    isActive: true
                ),
                WidgetFcyModel(
                    id: "EUR",
                    currency: "EUR",
                    imageData: nil,
                    buyPrice: CurrencyFormatter.format("17685.1400000"),
                    sellPrice: CurrencyFormatter.format("17862.7500000"),
                    isActive: true
                ),
                WidgetFcyModel(
                    id: "SGD",
                    currency: "SGD",
                    imageData: nil,
                    buyPrice: CurrencyFormatter.format("12117.0000000"),
                    sellPrice: CurrencyFormatter.format("12241.0000000"),
                    isActive: true
                ),
                WidgetFcyModel(
                    id: "JPY",
                    currency: "JPY",
                    imageData: nil,
                    buyPrice: CurrencyFormatter.format("112.9200000"),
                    sellPrice: CurrencyFormatter.format("114.0600000"),
                    isActive: true
                ),
                WidgetFcyModel(
                    id: "AUD",
                    currency: "AUD",
                    imageData: nil,
                    buyPrice: CurrencyFormatter.format("10792.0000000"),
                    sellPrice: CurrencyFormatter.format("10904.0400000"),
                    isActive: true
                )
            ]
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetFcyEntry) -> Void) {
        let entry = placeholder(in: context)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetFcyEntry>) -> Void) {
        Task {
            let items = await FCYWidgetClient.fetchForeignExchangeRates()
            var resultFcyRate: [WidgetFcyModel] = []
            let currentDate = Date()

            for item in items {
                let imageData: Data?
                if let urlString = item.image, !urlString.isEmpty {
                    imageData = await FCYWidgetClient.fetchImage(from: urlString)
                } else {
                    imageData = nil
                }

                let formattedBuyPrice = CurrencyFormatter.format(item.buyRate)
                let formattedSellPrice = CurrencyFormatter.format(item.sellRate)

                let fcyRate = WidgetFcyModel(
                    id: item._id ?? UUID().uuidString,
                    currency: item.currency ?? "N/A",
                    imageData: imageData,
                    buyPrice: formattedBuyPrice,
                    sellPrice: formattedSellPrice,
                    isActive: true
                )

                resultFcyRate.append(fcyRate)
            }

            // Fallback to placeholder if response items are empty
            let finalRates = resultFcyRate.isEmpty ? placeholder(in: context).fcyRates : resultFcyRate
            let entry = WidgetFcyEntry(date: currentDate, fcyRates: finalRates)

            // Update every 15 minutes
            let nextUpdate = Date().addingTimeInterval(15 * 60)
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))

            completion(timeline)
        }
    }
}

struct WidgetFcyEntryView: View {
    var entry: WidgetFcyProvider.Entry
    @SwiftUI.Environment(\.widgetFamily) var family

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

    // MARK: - Small Widget (Top 1 Rate)
    var smallWidgetView: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: "dollarsign.circle.fill")
                    .foregroundColor(.blue)
                    .font(.caption)
                Text("Kurs FCY")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }

            Spacer()

            if let topRate = entry.fcyRates.first {
                HStack(spacing: 6) {
                    if let data = topRate.imageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .clipShape(Circle())
                    } else {
                        Text("🔱")
                            .font(.system(size: 14))
                    }

                    Text(topRate.currency)
                        .font(.headline)
                        .fontWeight(.bold)
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text("Beli:")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(topRate.buyPrice)
                            .font(.caption2)
                            .fontWeight(.semibold)
                    }

                    HStack {
                        Text("Jual:")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(topRate.sellPrice)
                            .font(.caption2)
                            .fontWeight(.semibold)
                    }
                }
            } else {
                Text("Data tidak tersedia")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .widgetBackground(Color(UIColor.systemBackground))
    }

    // MARK: - Medium Widget (Top 3 Rates Grid)
    var mediumWidgetView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "banknote.fill")
                        .foregroundColor(.blue)
                        .font(.caption)
                    Text("KURS FCY JENIUS")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.blue)
                }
                Spacer()
                Text(entry.date, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Divider()

            HStack(spacing: 12) {
                ForEach(entry.fcyRates.prefix(3)) { rate in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 4) {
                            if let data = rate.imageData, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 16, height: 16)
                                    .clipShape(Circle())
                            }
                            Text(rate.currency)
                                .font(.subheadline)
                                .fontWeight(.bold)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Beli: \(rate.buyPrice)")
                                .font(.system(size: 10))
                                .foregroundColor(.green)
                            Text("Jual: \(rate.sellPrice)")
                                .font(.system(size: 10))
                                .foregroundColor(.red)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(8)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .widgetBackground(Color(UIColor.systemBackground))
    }

    // MARK: - Large Widget (Full Rates List)
    var largeWidgetView: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "banknote.fill")
                        .foregroundColor(.blue)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Jenius Foreign Exchange")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        Text("Daftar Kurs Mata Uang")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                }
                Spacer()
                Text(entry.date, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Divider()

            VStack(spacing: 8) {
                ForEach(entry.fcyRates) { rate in
                    HStack {
                        HStack(spacing: 8) {
                            if let data = rate.imageData, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "globe")
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.blue)
                            }

                            Text(rate.currency)
                                .font(.subheadline)
                                .fontWeight(.bold)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            HStack(spacing: 4) {
                                Text("Beli:")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text(rate.buyPrice)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.green)
                            }
                            HStack(spacing: 4) {
                                Text("Jual:")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text(rate.sellPrice)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .padding(8)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)
                }
            }

            Spacer()
        }
        .padding()
        .widgetBackground(Color(UIColor.systemBackground))
    }
}

struct WidgetFcy: Widget {
    let kind: String = "WidgetFcy"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WidgetFcyProvider()) { entry in
            WidgetFcyEntryView(entry: entry)
        }
        .configurationDisplayName("Kurs FCY Widget")
        .description("Pantau kurs mata uang asing terbaru dari Jenius FCY.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
