import WidgetKit
import SwiftUI

// MARK: - Data

struct DontSmokeEntry: TimelineEntry {
    let date: Date
    let slideIndex: Int
    let quitDateMillis: Int64
    let cigarettesPerDay: Int
    let costPerPack: Int
    let cigarettesPerPack: Int
}

// MARK: - Provider

struct DontSmokeProvider: TimelineProvider {

    private static let suiteName = "group.com.example.dontsmoke"

    func placeholder(in context: Context) -> DontSmokeEntry {
        DontSmokeEntry(date: Date(), slideIndex: 0,
                       quitDateMillis: -1, cigarettesPerDay: 0,
                       costPerPack: 0, cigarettesPerPack: 20)
    }

    func getSnapshot(in context: Context, completion: @escaping (DontSmokeEntry) -> Void) {
        completion(readEntry(slideIndex: 0, date: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DontSmokeEntry>) -> Void) {
        let now = Date()
        var entries: [DontSmokeEntry] = []
        for i in 0..<4 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: i * 30, to: now)!
            entries.append(readEntry(slideIndex: i, date: entryDate))
        }
        let refresh = Calendar.current.date(byAdding: .hour, value: 2, to: now)!
        completion(Timeline(entries: entries, policy: .after(refresh)))
    }

    private func readEntry(slideIndex: Int, date: Date) -> DontSmokeEntry {
        let defaults = UserDefaults(suiteName: Self.suiteName)
        let quitMillis = defaults?.object(forKey: "quit_date_millis") as? Int64 ?? -1
        let cpd  = defaults?.integer(forKey: "cigarettes_per_day") ?? 0
        let cpp  = defaults?.integer(forKey: "cost_per_pack") ?? 0
        let cpack = max(defaults?.integer(forKey: "cigarettes_per_pack") ?? 20, 1)

        return DontSmokeEntry(date: date, slideIndex: slideIndex,
                              quitDateMillis: quitMillis,
                              cigarettesPerDay: cpd,
                              costPerPack: cpp,
                              cigarettesPerPack: cpack)
    }
}

// MARK: - View

struct DontSmokeWidgetView: View {
    let entry: DontSmokeEntry

    private static let icons  = ["⏱", "💰", "🚭", "❤️"]
    private static let labels = [
        "Время без курения",
        "Сэкономлено",
        "Сигарет не выкурено",
        "Жизнь продлена"
    ]

    var body: some View {
        let (value, label) = calcStat()
        let icon = Self.icons[entry.slideIndex]

        ZStack {
            Color.black.opacity(0.8)

            VStack(spacing: 6) {
                Text(icon).font(.system(size: 24))

                Text(value)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)

                Text(label)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(1)

                HStack(spacing: 4) {
                    ForEach(0..<4, id: \.self) { i in
                        Circle()
                            .fill(i == entry.slideIndex
                                  ? Color.white
                                  : Color.white.opacity(0.4))
                            .frame(width: 5, height: 5)
                    }
                }
            }
            .padding(12)
        }
    }

    private func calcStat() -> (String, String) {
        let label = Self.labels[entry.slideIndex]
        guard entry.quitDateMillis > 0 else { return ("—", label) }

        let quitDate = Date(timeIntervalSince1970: Double(entry.quitDateMillis) / 1000.0)
        let diffMs = Int64(Date().timeIntervalSince(quitDate) * 1000)
        guard diffMs >= 0 else { return ("—", label) }

        let minutes = diffMs / 60_000
        let hours   = diffMs / 3_600_000
        let days    = diffMs / 86_400_000

        switch entry.slideIndex {
        case 0:
            let v: String
            if minutes < 60       { v = "\(minutes)м" }
            else if hours < 24    { v = "\(hours)ч \(minutes % 60)м" }
            else if days < 30     { v = "\(days)д \(hours % 24)ч" }
            else                  { v = "\(days / 30)мес \(days % 30)д" }
            return (v, label)
        case 1:
            let cpack = max(Int64(entry.cigarettesPerPack), 1)
            let saved = days * Int64(entry.cigarettesPerDay) * Int64(entry.costPerPack) / cpack
            return ("\(saved)₽", label)
        case 2:
            return ("\(days * Int64(entry.cigarettesPerDay))", label)
        default:
            let added = days * Int64(entry.cigarettesPerDay) * 11
            let v: String
            if added < 60        { v = "\(added)м" }
            else if added < 1440 { v = "\(added / 60)ч" }
            else                 { v = "\(added / 1440)д" }
            return (v, label)
        }
    }
}

// MARK: - Widget

@main
struct DontSmokeWidgetMain: Widget {
    let kind = "DontSmokeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DontSmokeProvider()) { entry in
            if #available(iOSApplicationExtension 17.0, *) {
                DontSmokeWidgetView(entry: entry)
                    .containerBackground(.black.opacity(0.8), for: .widget)
            } else {
                DontSmokeWidgetView(entry: entry)
            }
        }
        .configurationDisplayName("Не курю")
        .description("Статистика отказа от курения")
        .supportedFamilies([.systemSmall])
    }
}
