import Foundation

final class SitemapBuilder {

    let siteData: SiteData

    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter
    }()

    private var data: [(Date, String, String)] = []

    init(siteData: SiteData) {
        self.siteData = siteData
    }

    func process(stub: Stub) throws {
        let sitemapDate = try stub.sitemapDate
        let sitemapDateLastMod = try stub.sitemapDateLastMod
        let htmlName = try stub.htmlName

        guard stub.externalLink == nil else {
            // Ignore stubs that will not actually be generated
            return
        }

        let siteMapItem = """
        <url>
            <loc>https://\(siteData.domain)/\(htmlName)</loc>
            <lastmod>\(sitemapDateLastMod)</lastmod>
            <priority>0.80</priority>
        </url>
        <url>
            <loc>https://\(siteData.domain)/\(htmlName).html</loc>
            <lastmod>\(sitemapDateLastMod)</lastmod>
            <priority>0.80</priority>
        </url>

        """

        data.append((sitemapDate, siteMapItem, htmlName))
    }

    func end() -> String {
        let siteMapContent = data.sorted { $0.0 > $1.0 }.map { $0.1 }
        var siteMap = """
        <?xml version="1.0" encoding="UTF-8"?>
        <urlset
              xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
              xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
              xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9
                    http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd">

        """
        siteMapContent.forEach { siteMap += $0 }
        siteMap += "</urlset>"
        return siteMap
    }
}
