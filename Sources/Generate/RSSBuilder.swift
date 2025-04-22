import Foundation

final class RSSBuilder {

    let siteData: SiteData

    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss z"
        return dateFormatter
    }()

    private var data: [(Date, String)] = []

    init(siteData: SiteData) {
        self.siteData = siteData
    }

    func process(stub: Stub) throws {
        guard !stub.skipRSS else {
            return
        }

        let title = try stub.title
        let htmlName = stub.fileNameWithoutExtension
        let sitemapDate = try stub.sitemapDate
        let rssDateString = dateFormatter.string(from: sitemapDate)

        let rssLink: String = {
            if let externalLink = stub.externalLink {
                return externalLink
            } else {
                return "https://\(siteData.domain)/\(htmlName)"
            }
        }()

        let contents: String = cutDivs(
            times: siteData.rssDivCutCount,
            contents: Stub.resolveProperties(
                fromString: stub.rawContents,
                rawProperties: stub.rawProperties,
                siteData: siteData
            )
        )

        let item = """
            <item>
                <title>\(title)</title>
                <link>\(rssLink)</link>
                <guid>\(rssLink)</guid>
                <pubDate>\(rssDateString)</pubDate>
                <author>\(siteData.owner)</author>
            <description><![CDATA[\(contents)]]></description>
            </item>

            """

        data.append((sitemapDate, item))
    }

    func cutDivs(times: Int, contents: String) -> String {
        guard times > 0 else {
            return contents
        }
        var idx = contents.startIndex
        var foundDiv = 0
        while idx != contents.endIndex {
            let after = contents.index(idx, offsetBy: 1)
            let after2 = contents.index(idx, offsetBy: 2)
            let after3 = contents.index(idx, offsetBy: 3)
            if contents[idx] == "<" && contents[after] == "/" && contents[after2] == "d"
                && contents[after3] == "i"
            {
                foundDiv += 1
                if foundDiv == times {
                    let cutPoint = contents.index(idx, offsetBy: 6)
                    return String(contents[cutPoint...]).cutLastDiv
                }
            }
            idx = after
        }
        return contents
    }

    func end() -> String {
        let name = siteData.rssName ?? siteData.name
        let description = siteData.description
        let copyright = siteData.copyright
        let domain = siteData.domain
        let rssStart = """
            <?xml version="1.0" encoding="utf-8"?>
            <rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
            <channel>
                <title>\(name)</title>
                <description>\(description)</description>
                <language>en-us</language>
                <copyright>\(copyright)</copyright>
                <link>https://\(domain)</link>
                <atom:link href="https://\(domain)/rss.xml" rel="self" type="application/rss+xml"/>
            """
        var rssContent = data.sorted { $0.0 > $1.0 }.map { $0.1 }
        if let count = siteData.rssCount, count < rssContent.count {
            rssContent = Array(rssContent.prefix(upTo: count))
        }
        var rss = rssStart
        rssContent.forEach { rss += $0 }
        rss += "</channel></rss>"
        return rss
    }
}

extension String {
    fileprivate var cutLastDiv: String {
        var contents = self
        while contents.popLast() != "<" {
            continue
        }
        return contents
    }
}
