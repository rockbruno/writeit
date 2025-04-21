import Foundation

struct Stub: Hashable {

    enum Keys: String {
        case title = "WRITEIT_POST_NAME"
        case description = "WRITEIT_POST_SHORT_DESCRIPTION"
        case canonical = "WRITEIT_POST_CANONICAL"
        case sitemapDate = "WRITEIT_POST_SITEMAP_DATE"
        case sitemapLastMod = "WRITEIT_POST_SITEMAP_DATE_LAST_MOD"
        case externalLink = "WRITEIT_POST_EXTERNAL_LINK"
        case dontRSS = "WRITEIT_POST_DONT_RSS"
        case structuredJson = "WRITEIT_POST_STRUCTURED_JSON"
    }

    let fileName: String
    let rawContents: String
    let rawProperties: [String: String]

    private let sitemapDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter
    }()

    var fileNameWithoutExtension: String {
        return fileName.components(
            separatedBy: "."
        ).dropLast().joined(
            separator: "."
        )
    }

    init(file: File, siteData: SiteData) throws {
        self.fileName = file.name
        let rawContents = try file.contents
        self.rawContents = rawContents
        var rawProperties = {
            let regex = try? NSRegularExpression(
                pattern: "<!--(WRITEIT_POST[^=\n]*)=(.*)-->",
                options: []
            )
            let matches = regex?.matches(
                in: rawContents,
                options: [],
                range: NSRange(location: 0, length: rawContents.utf16.count)
            )
            let arr =
                matches?.compactMap { match -> (String, String) in
                    let nameRange = Range(match.range(at: 1), in: rawContents)!
                    let valueRange = Range(match.range(at: 2), in: rawContents)!
                    return (
                        String(rawContents[nameRange]),
                        String(rawContents[valueRange])
                    )
                } ?? []
            return [String: String](uniqueKeysWithValues: arr)
        }()
        if rawProperties[Keys.canonical.rawValue] == nil {
            rawProperties[Keys.canonical.rawValue] = {
                "https://\(siteData.domain)/$WRITEIT_POST_HTML_NAME"
            }()
        }
        self.rawProperties = rawProperties
    }

    var title: String {
        get throws {
            try get(property: Keys.title.rawValue)
        }
    }

    var description: String {
        get throws {
            try get(property: Keys.description.rawValue)
        }
    }

    var sitemapDateString: String {
        get throws {
            try get(property: Keys.sitemapDate.rawValue)
        }
    }

    var sitemapDate: Date {
        get throws {
            let dateString = try sitemapDateString
            guard let date = sitemapDateFormatter.date(from: dateString) else {
                throw StubError.cannotConvertSiteMapDate(fileName, dateString)
            }
            return date
        }
    }

    var sitemapDateLastMod: String {
        get throws {
            try get(property: Keys.sitemapLastMod.rawValue)
        }
    }

    var externalLink: String? {
        try? get(property: Keys.externalLink.rawValue)
    }

    var skipRSS: Bool {
        guard let str = try? get(property: Keys.dontRSS.rawValue) else {
            return false
        }
        return str == "true"
    }

    var canonical: String {
        get throws {
            try get(property: Keys.canonical.rawValue)
        }
    }

    var structuredJson: String? {
        try? get(property: Keys.structuredJson.rawValue)
    }

    func get(property: String) throws -> String {
        guard let result = rawProperties[property] else {
            throw StubError.noProperty(fileName, property)
        }
        return result
    }
}

extension Stub {
    static func resolveProperties(
        fromString string: String,
        rawProperties: [String: String],
        siteData: SiteData
    ) -> String {
        var contents = string
        let properties: [(String, String)] = Array(
            rawProperties
        ).sorted(by: { $0.key < $1.key })
        for _ in 0..<siteData.propertyDepth {
            properties.forEach {
                contents = contents.replacingOccurrences(
                    of: "$\($0.0)",
                    with: $0.1
                )
            }
        }
        return contents
    }
}

private enum StubError: LocalizedError {
    case noProperty(String, String)
    case cannotConvertSiteMapDate(String, String)

    var errorDescription: String? {
        switch self {
        case .noProperty(let htmlName, let property):
            return "Stub \(htmlName) is missing required property \(property)"
        case .cannotConvertSiteMapDate(let htmlName, let date):
            return "Sitemap date format is invalid in \(htmlName): \(date)"
        }
    }
}
