import Foundation

struct SiteData: Decodable {

    enum CodingKeys: CodingKey {
        case domain
        case name
        case output_path
        case description
        case thumbnail_path
        case copyright
        case owner
        case rss_name
        case property_depth
        case rss_div_cut_count
        case rss_count
    }

    let domain: String
    let name: String
    let outputPath: String
    let description: String
    let thumbPath: String
    let copyright: String?
    let owner: String
    let rssName: String?
    let rssCount: Int?
    let propertyDepth: Int
    let rssDivCutCount: Int

    private static func get(
        _ key: String,
        inDict dict: [String: String]
    ) throws -> String {
        guard let value = dict[key] else {
            throw SiteDataError.noValueForKey(key)
        }
        return value
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.domain = try container.decode(String.self, forKey: .domain)
        self.name = try container.decode(String.self, forKey: .name)
        let _outputPath = try container.decode(String.self, forKey: .output_path)
        self.outputPath = URL(filePath: _outputPath).absoluteURL.path()
        self.description = try container.decode(String.self, forKey: .description)
        let owner = try container.decode(String.self, forKey: .owner)
        self.owner = owner
        self.thumbPath = try container.decode(String.self, forKey: .thumbnail_path)
        self.rssName = try container.decodeIfPresent(String.self, forKey: .rss_name)
        self.rssCount = try container.decodeIfPresent(Int.self, forKey: .rss_count)
        self.propertyDepth = (try container.decodeIfPresent(Int.self, forKey: .property_depth)) ?? 2
        self.rssDivCutCount = (try container.decodeIfPresent(Int.self, forKey: .rss_div_cut_count)) ?? 0
        self.copyright = (try container.decodeIfPresent(
            String.self,
            forKey: .copyright
        )) ?? "\(owner) \(Calendar.current.component(.year, from: .now))"
    }

    static func create(fromFile file: File) throws -> SiteData {
        let data = try Data(contentsOf: file.url)
        let decoder = JSONDecoder()
        return try decoder.decode(SiteData.self, from: data)
    }
}

private enum SiteDataError: LocalizedError {
    case noValueForKey(String)

    var errorDescription: String? {
        switch self {
        case .noValueForKey(let key):
            return "SiteData is missing value for key '\(key)'"
        }
    }
}
