import Foundation

// FIXME: make json
struct SiteData {
    let domain: String
    let name: String
    let outputPath: String
    let description: String
    let thumbPath: String
    let copyright: String // FIXME: automatic?
    let owner: String
    let rssName: String?

    private let _propertyDepth: String?
    private static let defaultPropertyDepth = 2
    var propertyDepth: Int {
        guard let _propertyDepth else {
            return Self.defaultPropertyDepth
        }
        return Int(_propertyDepth) ?? Self.defaultPropertyDepth
    }


    private let _rssDivCutCount: String?
    private static let defaultRssDivCutCount = 0
    var rssDivCutCount: Int {
        guard let _rssDivCutCount else {
            return Self.defaultRssDivCutCount
        }
        return Int(_rssDivCutCount) ?? Self.defaultRssDivCutCount
    }

    private let _rssCount: String?
    var rssCount: Int? {
        guard let _rssCount else {
            return nil
        }
        return Int(_rssCount)
    }

    private static func get(
        _ key: String,
        inDict dict: [String: String]
    ) throws -> String {
        guard let value = dict[key] else {
            throw SiteDataError.noValueForKey(key)
        }
        return value
    }

    init(dict: [String: String]) throws {
        self.domain = try Self.get("domain", inDict: dict)
        self.name = try Self.get("name", inDict: dict)
        self.outputPath = try Self.get("output_path", inDict: dict)
        self.description = try Self.get("description", inDict: dict)
        self.copyright = try Self.get("copyright", inDict: dict)
        self.owner = try Self.get("owner", inDict: dict)
        self.thumbPath = try Self.get("thumbnail_path", inDict: dict)
        self.rssName = try? Self.get("rss_name", inDict: dict)
        self._rssCount = try? Self.get("rss_count", inDict: dict)
        self._propertyDepth = try? Self.get("property_depth", inDict: dict)
        self._rssDivCutCount = try? Self.get("rss_div_cut_count", inDict: dict)
    }

    init(file: File) throws {
        let siteDataRaw = try file.contents
        let components = siteDataRaw.components(
            separatedBy: "\n"
        ).map {
            $0.components(separatedBy: ":")
        }
        var dict = [String: String]()
        for data in components {
            dict[data[0]] = data[1]
        }
        try self.init(dict: dict)
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
