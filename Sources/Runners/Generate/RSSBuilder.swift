import Foundation

final class RSSBuilder {

    let siteData: SiteData

    struct Entry {
        let publishedDateStr: String
        let publishedDate: Date
        let lastModStr: String
        let lastModDate: Date
        let content: String
    }

    private var data: [Entry] = []

    init(siteData: SiteData) {
        self.siteData = siteData
    }

    func process(stub: Stub) throws {
        guard !stub.skipRSS else {
            return
        }

        let domain = siteData.domain
        let title = try stub.title
        let owner = siteData.owner
        let description = try stub.description
        let htmlName = stub.fileNameWithoutExtension
        let sitemapDateString = try stub.sitemapDateString
        let sitemapDate = try stub.sitemapDate
        let sitemapDateLastModString = try stub.sitemapDateLastModString
        let sitemapDateLastMod = try stub.sitemapDateLastMod

        let rssLink: String = {
            if let externalLink = stub.externalLink {
                return externalLink
            } else {
                return "https://\(domain)/\(htmlName)"
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

        let content = """
        <entry>
            <title>\(title)</title>
            <link href="\(rssLink)" rel="alternate" type="text/html" title="\(title)"/>
            <published>\(sitemapDateString)</published>
            <updated>\(sitemapDateLastModString)</updated>
            <id>\(rssLink)</id>
            <author>
                <name>\(owner)</name>
            </author>
            <summary>\(description)</summary>
            <content type="text/html"><![CDATA[\(contents)]]></content>
        </entry>
        """

        let entry = Entry(
            publishedDateStr: sitemapDateString,
            publishedDate: sitemapDate,
            lastModStr: sitemapDateLastModString,
            lastModDate: sitemapDateLastMod,
            content: content
        )

        data.append(entry)
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
        var _content = data.sorted { $0.publishedDate > $1.publishedDate }
        if let count = siteData.rssCount, count < _content.count {
            _content = Array(_content.prefix(upTo: count))
        }
        let lastUpdated = _content.max {
            $0.lastModDate <= $1.lastModDate
        }?.lastModStr ?? ""
        let content = _content.map { $0.content }

        let name = siteData.rssName ?? siteData.name
        let description = siteData.description
        let copyright = siteData.copyright
        let domain = siteData.domain
        let owner = siteData.owner
        let path = siteData.rssFileName
        let rssStart = """
        <feed xmlns="http://www.w3.org/2005/Atom">
            <id>https://\(domain)</id>
            <title>\(name)</title>
            <subtitle>\(description)</subtitle>
            <updated>\(lastUpdated)</updated>
            <author>
                <name>\(owner)</name>
                <uri>https://\(domain)</uri>
            </author>
            <link rel="self" type="application/atom+xml" href="https://\(domain)/\(path)"/>
            <link rel="alternate" type="text/html" hreflang="en" href="https://\(domain)"/>
            <generator uri="https://github.com/rockbruno/writeit">WriteIt</generator>
            <rights> © \(copyright) </rights>
        """
        var rss = rssStart
        content.forEach { rss += $0 }
        rss += "</feed>"
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
