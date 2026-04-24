import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Constants

private let suiteName = "group.com.dontsmoke.kz"

// MARK: - App Intents (iOS 17+)

@available(iOS 16.0, *)
struct NextSlideIntent: AppIntent {
    static var title: LocalizedStringResource = "Next Slide"

    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: suiteName)
        let current = defaults?.integer(forKey: "widget_slide_index") ?? 0
        defaults?.set((current + 1) % 4, forKey: "widget_slide_index")
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

    private static let suiteName = "group.com.dontsmoke.kz"

    func placeholder(in context: Context) -> DontSmokeEntry {
        DontSmokeEntry(date: Date(), slideIndex: 0, bgStyle: "dark",
                       quitDateMillis: -1, cigarettesPerDay: 0,
                       costPerPack: 0, cigarettesPerPack: 20)
    }

    func getSnapshot(in context: Context, completion: @escaping (DontSmokeEntry) -> Void) {
        completion(readEntry(date: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DontSmokeEntry>) -> Void) {
        let entry = readEntry(date: Date())
        let refresh = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(refresh)))
    }

    private func readEntry(date: Date) -> DontSmokeEntry {
        let defaults = UserDefaults(suiteName: suiteName)
        let slideIndex = defaults?.integer(forKey: "widget_slide_index") ?? 0
        let bgStyle    = defaults?.string(forKey: "widget_bg_style") ?? "dark"
        let quitMillis = defaults?.object(forKey: "quit_date_millis") as? Int64 ?? -1
        let cpd        = defaults?.integer(forKey: "cigarettes_per_day") ?? 0
        let cpp        = defaults?.integer(forKey: "cost_per_pack") ?? 0
        let cpack      = max(defaults?.integer(forKey: "cigarettes_per_pack") ?? 20, 1)

        return DontSmokeEntry(date: date, slideIndex: slideIndex, bgStyle: bgStyle,
                              quitDateMillis: quitMillis, cigarettesPerDay: cpd,
                              costPerPack: cpp, cigarettesPerPack: cpack)
    }
}

// MARK: - View

struct DontSmokeWidgetView: View {
    let entry: DontSmokeEntry

    private static let icons  = ["⏱", "💰", "🚭", "❤️"]
    private static let labels = ["Время", "Сэкономлено", "Сигарет", "Здоровье"]

    // Настраиваем цвета в зависимости от темы
    private var textColor: Color {
        switch entry.bgStyle {
        case "light": return .black
        case "glass": return .primary // Адаптируется под системную тему под стеклом
        default: return .white // "dark"
        }
    }

    private var secondaryColor: Color {
        switch entry.bgStyle {
        case "light": return Color.black.opacity(0.55)
        case "glass": return .secondary // Адаптируется под системную тему
        default: return Color.white.opacity(0.7)
        }
    }

    private var bgIconName: String {
        switch entry.bgStyle {
        case "light": return "sun.max.fill"
        case "glass": return "sparkles" // Иконка для стеклянного режима
        default: return "moon.fill"
        }
    }

    var body: some View {
        let (value, label) = calcStat()
        let icon = Self.icons[entry.slideIndex]

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

            // Центральный контент — тап для следующего слайда
            if #available(iOS 17.0, *) {
                Button(intent: NextSlideIntent()) {
                    slideContent(icon: icon, value: value, label: label)
                }
                .buttonStyle(.plain)
            } else {
                slideContent(icon: icon, value: value, label: label)
            }

            Spacer()

            // Индикаторы слайдов
            HStack(spacing: 5) {
                ForEach(0..<4, id: \.self) { i in
                    Capsule()
                        .fill(i == entry.slideIndex ? textColor : secondaryColor.opacity(0.5))
                        .frame(width: i == entry.slideIndex ? 14 : 5, height: 4)
                        .animation(.easeInOut(duration: 0.2), value: entry.slideIndex)
                }
            }
            .padding(.bottom, 10)
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
                    .invalidatableContent()
                    .containerBackground(for: .widget) {
                        widgetBackground(for: entry.bgStyle)
                    }
            } else {
                DontSmokeWidgetView(entry: entry)
                    .background(widgetBackground(for: entry.bgStyle))
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