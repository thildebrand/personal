import Foundation

struct SnowReportDecodable: Decodable {
    var date = Date()
    
    var villageTemp: Int
    var ripperTemp: Int
    var subpeakTemp: Int
    
    var windSpeed: Int
    var windDirection: String
    
    var overnightSnow: Int
    var twentyfourHourSnow: Int
    var fourtyeightHourSnow: Int
    
    init() {
        self.villageTemp = 0
        self.ripperTemp = 0
        self.subpeakTemp = 0
        self.windSpeed = 0
        self.windDirection = ""
        self.overnightSnow = 0
        self.twentyfourHourSnow = 0
        self.fourtyeightHourSnow = 0
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let subpeakData = try container.nestedContainer(keyedBy: SubpeakCodingKeys.self, forKey: .subpeak)
        let ripperData = try container.nestedContainer(keyedBy: SummitCodingKeys.self, forKey: .summit)
        let villageData = try container.nestedContainer(keyedBy: VillageCodingKeys.self, forKey: .weather)
        let snowData = try container.nestedContainer(keyedBy: SnowCodingKeys.self, forKey: .snow)
        
        self.subpeakTemp = try subpeakData.decodeIfPresent(Int.self, forKey: .temperature) ?? 0
        
        self.ripperTemp = try ripperData.decodeIfPresent(Int.self, forKey: .temperature) ?? 0
        self.windSpeed = try ripperData.decodeIfPresent(Int.self, forKey: .wind) ?? 0
        self.windDirection = try ripperData.decodeIfPresent(String.self, forKey: .direction) ?? ""
        
        self.villageTemp = try villageData.decodeIfPresent(String.self, forKey: .temperature).flatMap { Int($0) } ?? 0
        
        self.overnightSnow = try snowData.decodeIfPresent(Int.self, forKey: .overnight) ?? 0
        self.twentyfourHourSnow = try snowData.decodeIfPresent(Int.self, forKey: .twentyfourhour) ?? 0
        self.fourtyeightHourSnow = try snowData.decodeIfPresent(Int.self, forKey: .fortyeighthour) ?? 0
    }
    
    enum CodingKeys: String, CodingKey {
        case weather
        case summit
        case subpeak
        case snow
    }
    
    enum VillageCodingKeys: String, CodingKey {
        case temperature
    }
    
    enum SummitCodingKeys: String, CodingKey {
        case temperature
        case wind
        case direction
    }
    
    enum SubpeakCodingKeys: String, CodingKey {
        case temperature
    }
    
    enum SnowCodingKeys: String, CodingKey {
        case overnight
        case twentyfourhour
        case fortyeighthour
    }
}
