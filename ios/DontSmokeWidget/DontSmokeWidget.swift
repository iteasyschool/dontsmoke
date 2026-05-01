import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Constants

private let suiteName = "group.kz.dontsmoke.app"
private let widgetKind = "DontSmokeWidget"
private let timelineHorizonMinutes = 120

// MARK: - App Intents (iOS 17+)

@available(iOS 16.0, *)
struct PreviousSlideIntent: AppIntent {
    static var title: LocalizedStringResource = "Previous Slide"

    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: suiteName)
        let current = defaults?.integer(forKey: "widget_slide_index") ?? 0
        defaults?.set((current + 3) % 4, forKey: "widget_slide_index")
        WidgetCenter.shared.reloadTimelines(ofKind: widgetKind)
        return .result()
    }
}

@available(iOS 16.0, *)
struct NextSlideIntent: AppIntent {
    static var title: LocalizedStringResource = "Next Slide"

    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: suiteName)
        let current = defaults?.integer(forKey: "widget_slide_index") ?? 0
        defaults?.set((current + 1) % 4, forKey: "widget_slide_index")
        WidgetCenter.shared.reloadTimelines(ofKind: widgetKind)
        return .result()
    }
}

@available(iOS 16.0, *)
struct CycleBgIntent: AppIntent {
    static var title: LocalizedStringResource = "Change Background"

    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: suiteName)
        // Добавлен третий режим - glass (стекло)
        let themes = ["dark", "light", "glass"]
        let current = defaults?.string(forKey: "widget_bg_style") ?? "dark"
        let idx = themes.firstIndex(of: current) ?? 0
        defaults?.set(themes[(idx + 1) % themes.count], forKey: "widget_bg_style")
        WidgetCenter.shared.reloadTimelines(ofKind: widgetKind)
        return .result()
    }
}

// MARK: - Data

struct DontSmokeEntry: TimelineEntry {
    let date: Date
    let slideIndex: Int
    let bgStyle: String
    let quitDateMillis: Int64
    let cigarettesPerDay: Int
    let costPerPack: Int
    let cigarettesPerPack: Int
}

// MARK: - Provider

struct DontSmokeProvider: TimelineProvider {

    func placeholder(in context: Context) -> DontSmokeEntry {
        DontSmokeEntry(date: Date(), slideIndex: 0, bgStyle: "dark",
                       quitDateMillis: -1, cigarettesPerDay: 0,
                       costPerPack: 0, cigarettesPerPack: 20)
    }

    func getSnapshot(in context: Context, completion: @escaping (DontSmokeEntry) -> Void) {
        completion(readEntry(date: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DontSmokeEntry>) -> Void) {
        let now = Date()
        let entry = readEntry(date: now)
        let dates = timelineDates(from: now, quitDateMillis: entry.quitDateMillis)
        let entries = dates.map { readEntry(date: $0) }
        let refresh = dates.last?.addingTimeInterval(60) ?? now.addingTimeInterval(60 * 60)
        completion(Timeline(entries: entries, policy: .after(refresh)))
    }

    private func readEntry(date: Date) -> DontSmokeEntry {
        let defaults = UserDefaults(suiteName: suiteName)
        let slideIndex = currentSlideIndex()
        let bgStyle    = currentBgStyle()
        let quitMillis = defaults?.object(forKey: "quit_date_millis") as? Int64 ?? -1
        let cpd        = defaults?.integer(forKey: "cigarettes_per_day") ?? 0
        let cpp        = defaults?.integer(forKey: "cost_per_pack") ?? 0
        let cpack      = max(defaults?.integer(forKey: "cigarettes_per_pack") ?? 20, 1)

        return DontSmokeEntry(date: date, slideIndex: slideIndex, bgStyle: bgStyle,
                              quitDateMillis: quitMillis, cigarettesPerDay: cpd,
                              costPerPack: cpp, cigarettesPerPack: cpack)
    }

    private func timelineDates(from start: Date, quitDateMillis: Int64) -> [Date] {
        var dates = [start]

        var firstMinuteRefresh = start.addingTimeInterval(60)
        if quitDateMillis > 0 {
            let quitDate = Date(timeIntervalSince1970: Double(quitDateMillis) / 1000.0)
            let elapsed = start.timeIntervalSince(quitDate)
            if elapsed >= 0 {
                let remainder = elapsed.truncatingRemainder(dividingBy: 60)
                let secondsToNextMinute = remainder == 0 ? 60 : 60 - remainder
                firstMinuteRefresh = start.addingTimeInterval(secondsToNextMinute + 0.25)
            }
        }

        for minute in 0..<timelineHorizonMinutes {
            dates.append(firstMinuteRefresh.addingTimeInterval(Double(minute) * 60))
        }

        return dates
    }
}

private func currentSlideIndex() -> Int {
    let defaults = UserDefaults(suiteName: suiteName)
    return min(max(defaults?.integer(forKey: "widget_slide_index") ?? 0, 0), 3)
}

private func currentBgStyle() -> String {
    let defaults = UserDefaults(suiteName: suiteName)
    return defaults?.string(forKey: "widget_bg_style") ?? "dark"
}

// MARK: - View

struct DontSmokeWidgetView: View {
    let entry: DontSmokeEntry

    private static let icons  = ["⏱", "💰", "🚭", "❤️"]
    private static let labels = ["Время", "Сэкономлено", "Сигарет", "Здоровье"]
    private var slideIndex: Int { currentSlideIndex() }
    private var bgStyle: String { currentBgStyle() }

    // Настраиваем цвета в зависимости от темы
    private var textColor: Color {
        switch bgStyle {
        case "light": return .black
        case "glass": return .primary // Адаптируется под системную тему под стеклом
        default: return .white // "dark"
        }
    }

    private var secondaryColor: Color {
        switch bgStyle {
        case "light": return Color.black.opacity(0.55)
        case "glass": return .secondary // Адаптируется под системную тему
        default: return Color.white.opacity(0.7)
        }
    }

    private var bgIconName: String {
        switch bgStyle {
        case "light": return "sun.max.fill"
        case "glass": return "sparkles" // Иконка для стеклянного режима
        default: return "moon.fill"
        }
    }

    var body: some View {
        let (value, label) = calcStat()
        let icon = Self.icons[slideIndex]

        VStack(spacing: 0) {
            // Верхняя строка: иконка темы справа
            HStack {
                Spacer()
                if #available(iOS 17.0, *) {
                    Button(intent: CycleBgIntent()) {
                        Image(systemName: bgIconName)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(secondaryColor)
                            .frame(width: 22, height: 22)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 10)
            .padding(.top, 8)

            Spacer()

            slideCarouselContent(icon: icon, value: value, label: label)

            Spacer()

            // Индикаторы слайдов
            HStack(spacing: 5) {
                ForEach(0..<4, id: \.self) { i in
                    Capsule()
                        .fill(i == slideIndex ? textColor : secondaryColor.opacity(0.5))
                        .frame(width: i == slideIndex ? 14 : 5, height: 4)
                        .animation(.easeInOut(duration: 0.2), value: slideIndex)
                }
            }
            .padding(.bottom, 10)
        }
    }

    @ViewBuilder
    private func slideCarouselContent(icon: String, value: String, label: String) -> some View {
        if #available(iOS 17.0, *) {
            ZStack {
                slideContent(icon: icon, value: value, label: label)

                HStack(spacing: 0) {
                    Button(intent: PreviousSlideIntent()) {
                        Color.clear
                    }
                    .buttonStyle(.plain)

                    Button(intent: NextSlideIntent()) {
                        Color.clear
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: .infinity)
        } else {
            slideContent(icon: icon, value: value, label: label)
        }
    }

    @ViewBuilder
    private func slideContent(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 5) {
            Text(icon)
                .font(.system(size: 26))

            Text(value)
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(textColor)
                .minimumScaleFactor(0.4)
                .lineLimit(1)

            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(secondaryColor)
                .lineLimit(1)
        }
    }

    private func calcStat() -> (String, String) {
        let label = Self.labels[slideIndex]
        guard entry.quitDateMillis > 0 else { return ("—", label) }

        let quitDate = Date(timeIntervalSince1970: Double(entry.quitDateMillis) / 1000.0)
        let diffSeconds = entry.date.timeIntervalSince(quitDate)
        guard diffSeconds >= 0 else { return ("—", label) }

        let minutes = Int64(diffSeconds / 60)
        let hours   = Int64(diffSeconds / 3600)
        let days    = Int64(diffSeconds / 86400)
        
        let fractionalDays = diffSeconds / 86400.0

        switch slideIndex {
        case 0:
            let v: String
            if minutes < 60       { v = "\(minutes)м" }
            else if hours < 24    { v = "\(hours)ч \(minutes % 60)м" }
            else if days < 30     { v = "\(days)д \(hours % 24)ч" }
            else                  { v = "\(days / 30)мес \(days % 30)д" }
            return (v, label)
        case 1:
            let cpp = Double(entry.costPerPack)
            let cpd = Double(entry.cigarettesPerDay)
            let cpack = Double(max(entry.cigarettesPerPack, 1))
            let cigarettesSaved = fractionalDays * cpd
            let packsSaved = cigarettesSaved / cpack
            let saved = packsSaved * cpp
            return ("\(Int64(saved))", label)
        case 2:
            let avoided = fractionalDays * Double(entry.cigarettesPerDay)
            return ("\(Int64(avoided.rounded()))", label)
        default:
            // Health: 11 minutes per cigarette avoided
            let addedMins = fractionalDays * Double(entry.cigarettesPerDay) * 11
            let v: String
            if addedMins < 60        { v = "\(Int64(addedMins))м" }
            else if addedMins < 1440 { v = "\(Int64(addedMins / 60))ч" }
            else                     { v = "\(Int64(addedMins / 1440))д" }
            return (v, label)
        }
    }
}

// MARK: - Widget

@main
struct DontSmokeWidgetMain: Widget {
    let kind = widgetKind

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DontSmokeProvider()) { entry in
            if #available(iOSApplicationExtension 17.0, *) {
                DontSmokeWidgetView(entry: entry)
                    .containerBackground(for: .widget) {
                        widgetBackground(for: currentBgStyle())
                    }
            } else {
                DontSmokeWidgetView(entry: entry)
                    .background(widgetBackground(for: currentBgStyle()))
            }
        }
        .configurationDisplayName("Не курю")
        .description("Статистика отказа от курения")
        .supportedFamilies([.systemSmall])
    }
    
    // Вспомогательная функция для генерации фона
    @ViewBuilder
    func widgetBackground(for style: String) -> some View {
        switch style {
        case "light":
            Color.white.opacity(0.92)
        case "glass":
            // Создает красивый эффект размытия (стекла)
            Rectangle().fill(.ultraThinMaterial)
        default: // "dark"
            Color.black.opacity(0.85)
        }
    }
}
