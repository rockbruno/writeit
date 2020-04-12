import Foundation

final class PageGenerator {

    static var path = "./public"

    init() {}
    func run() {
        let templateContents = File.pageTemplate.contents
        let stubs = FileManager.files(atPath: StubGenerator.path, suffix: ".html")
        guard stubs.isEmpty == false else {
            print("Error: There are no stubs to generate files from in this folder.")
            exit(1)
        }
        var rssContent = [(Date, String)]()
        var siteMapContent = [(Date, String)]()
        stubs.forEach { stub in
            autoreleasepool {
                let contents = stub.contents
                let page = generate(fromStub: contents, template: templateContents)
                page.write(toPath: PageGenerator.path + "/" + stub.name)
                addToRss(&rssContent, &siteMapContent, stub: contents)
            }
        }
        let rss = end(rss: rssContent)
        rss.write(toPath: PageGenerator.path + "/rss.xml")
        let siteMap = end(siteMap: siteMapContent)
        siteMap.write(toPath: PageGenerator.path + "/sitemap.xml")
    }

    func generate(fromStub stub: String, template: String) -> String {
        let identifier = "id=\"WRITEIT_DYNAMIC_CONTENT\">"
        guard let startingPos = template.range(of: identifier) else {
            print("Error: Could not locate the dynamic content div inside the template.")
            exit(1)
        }
        let prefix = String(template[template.startIndex..<startingPos.upperBound])
        let suffix = String(template[startingPos.upperBound...])
        let rawPage = prefix + stub + suffix
        let stubProperties = stub.properties
        return rawPage.replace(properties: stubProperties)
    }

    func rssStart() -> String {
        return """
        <?xml version="1.0" encoding="utf-8"?>
        <rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
        <channel>
            <title>SwiftRocks</title>
            <description>SwiftRocks is a blog about how Swift works and general iOS tips and tricks.</description>
            <language>en-us</language>
            <copyright>2019 Bruno Rocha</copyright>
            <link>https://swiftrocks.com</link>
            <atom:link href="https://swiftrocks.com/rss.xml" rel="self" type="application/rss+xml"/>
        """
    }

    func addToRss(_ rss: inout [(Date, String)], _ sitemap: inout [(Date, String)], stub: String) {
        let dict = [String:String](uniqueKeysWithValues: stub.properties)

        let title = dict["WRITEIT_POST_NAME"] ?? "No Title"
        let sitemapDate = dict["WRITEIT_POST_SITEMAP_DATE"] ?? "No Date"
        let html = dict["WRITEIT_POST_HTML_NAME"] ?? "No html"

        if html == "index" {
            return
        }

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = dateFormatter.date(from:sitemapDate)!
        let rssFormatter = DateFormatter()
        rssFormatter.locale = dateFormatter.locale
        rssFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss z"
        let rssDateString = rssFormatter.string(from: date)

        let contents = stub.replace(properties: stub.properties)
        let item = """
        <item>
            <title>\(title)</title>
            <link>https://swiftrocks.com/\(html)</link>
            <guid>https://swiftrocks.com/\(html)</guid>
            <pubDate>\(rssDateString)</pubDate>
        <description><![CDATA[\(contents)]]></description>
        </item>

        """

        rss.append((date, item))

        let siteMapItem = """
        <url>
            <loc>https://swiftrocks.com/\(html)</loc>
            <lastmod>\(sitemapDate)</lastmod>
            <priority>0.80</priority>
        </url>

        """

        sitemap.append((date, siteMapItem))
    }

    func end(rss: [(Date, String)]) -> String {
        let rssContent = rss.sorted { $0.0 > $1.0 }.map { $0.1 }
        var rss = """
        <?xml version="1.0" encoding="utf-8"?>
        <rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
        <channel>
            <title>SwiftRocks</title>
            <description>SwiftRocks is a blog about how Swift works and general iOS tips and tricks.</description>
            <language>en-us</language>
            <copyright>2019 Bruno Rocha</copyright>
            <link>https://swiftrocks.com</link>
            <atom:link href="https://swiftrocks.com/rss.xml" rel="self" type="application/rss+xml"/>
        """
        rssContent.forEach { rss += $0 }
        rss += "</channel></rss>"
        return rss
    }

    func end(siteMap: [(Date, String)]) -> String {
        let siteMapContent = siteMap.sorted { $0.0 > $1.0 }.map { $0.1 }
        var siteMap = """
        <?xml version="1.0" encoding="UTF-8"?>
        <urlset
              xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
              xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
              xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9
                    http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd">
        <!-- created with Free Online Sitemap Generator www.xml-sitemaps.com -->


        <url>
          <loc>https://swiftrocks.com/</loc>
          <lastmod>2018-10-29T12:21:52+00:00</lastmod>
          <priority>1.00</priority>
        </url>
        """
        siteMapContent.forEach { siteMap += $0 }
        siteMap += "</urlset>"
        return siteMap
    }
}

extension String {
    var properties: [(String, String)] {
        let regex = try? NSRegularExpression(
            pattern: "<!--(WRITEIT_POST[^=\n]*)=(.*)-->",
            options: []
        )
        let matches = regex?.matches(
            in: self,
                    options: [],
                                     range: NSRange(location: 0, length: self.utf16.count))
        return matches?.compactMap { match -> (String, String) in
            let nameRange = Range(match.range(at: 1), in: self)
            let valueRange = Range(match.range(at: 2), in: self)
            return (String(self[nameRange!]),
                    String(self[valueRange!]))
        } ?? []
    }
}

extension String {
    func replace(properties: [(String, String)]) -> String {
        var page = self
        properties.forEach {
            page = page.replacingOccurrences(of: "$\($0.0)", with: $0.1)
        }
        return page
    }
}
