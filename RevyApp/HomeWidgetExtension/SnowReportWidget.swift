import SwiftUI
import WidgetKit

struct SnowReportProvider: TimelineProvider {
    func placeholder(in context: Context) -> SnowReportEntry {
        SnowReportEntry(snowReport: SnowReportDecodable())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SnowReportEntry) -> Void) {
        Task {
            do {
                let snowReport = try await fetchSnowReport()
                let entry = SnowReportEntry(snowReport: snowReport)
                completion(entry)
            } catch {
                let defaultEntry = SnowReportEntry(snowReport: SnowReportDecodable())
                completion(defaultEntry)
            }
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SnowReportEntry>) -> Void) {
        getSnapshot(in: context) { entry in
            let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 10, to: Date())!
            
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
            
            completion(timeline)
        }
    }
    
    private func fetchSnowReport() async throws -> SnowReportDecodable {
            guard let url = URL(string: "https://www.revelstokemountainresort.com/snow-weather-json/") else { throw URLError(.badURL) }
            
        let (data, _) = try await URLSession.shared.data(from: url)
            
        do {
            return try JSONDecoder().decode(SnowReportDecodable.self, from: data)
        } catch {
            print("Error decoding JSON: \(error)")
            return SnowReportDecodable()
        }
    }
}

struct SnowReportView: View {
    var entry: SnowReportProvider.Entry
    var body: some View {
        SnowReportMedium(entry: entry).containerBackground(Color.black, for: .widget)
    }
}

struct SnowReportMedium: View {
    var entry: SnowReportProvider.Entry
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Subpeak Temp: \(entry.subpeakTemp)")
            Text("Ripper Temp: \(entry.ripperTemp)")
            Text("Village Temp: \(entry.villageTemp)")
            Text("Wind Speed: \(entry.windSpeed)")
            Text("Overnight Snow: \(entry.overnightSnow)")
            Text("24hr Snow: \(entry.twentyfourHourSnow)")
            Text("48hr Snow: \(entry.fourtyeightHourSnow)")
        }
        .font(.system(size: 10.0))
        .foregroundColor(.white)  // Set the text color to white
    }
}

struct SnowReportWidget: Widget {
    private let kind: String = "SnowReportWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SnowReportProvider()) { entry in
            SnowReportView(entry: entry)
        }.supportedFamilies([.systemMedium])
    }
}

struct SnowReportWidgetPreview: PreviewProvider {
    static var previews: some View {
        SnowReportView(entry: SnowReportEntry(snowReport: SnowReportDecodable())).previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}

struct SnowReportEntry: TimelineEntry {
    var date: Date = Date()
    
    var villageTemp: Int
    var ripperTemp: Int
    var subpeakTemp: Int
    
    var windSpeed: Int
    var windDirection: String
    
    var overnightSnow: Int
    var twentyfourHourSnow: Int
    var fourtyeightHourSnow: Int
    
    init(snowReport: SnowReportDecodable) {
        self.villageTemp = snowReport.villageTemp
        self.ripperTemp = snowReport.ripperTemp
        self.subpeakTemp = snowReport.subpeakTemp
        
        self.windSpeed = snowReport.windSpeed
        self.windDirection = snowReport.windDirection
        
        self.overnightSnow = snowReport.overnightSnow
        self.twentyfourHourSnow = snowReport.twentyfourHourSnow
        self.fourtyeightHourSnow = snowReport.fourtyeightHourSnow
    }
}
