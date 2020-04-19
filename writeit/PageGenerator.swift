import Foundation

final class PageGenerator {

    static var path = "./public"

    init() {}

    func run() {
        let templateContents = File.pageTemplate.contents
        // Leave index for last to make adding the structured json easier
        let stubs = FileManager.files(atPath: StubGenerator.path, suffix: ".html").sorted {
            $0.name != "index.html" || $1.name != "index.html"
        }
        guard stubs.isEmpty == false else {
            print("Error: There are no stubs to generate files from in this folder.")
            exit(1)
        }
        var rssContent = [(Date, String)]()
        var siteMapContent = [(Date, String)]()
        var jsons = [(Date, String)]()
        stubs.forEach { stub in
            autoreleasepool {
                let contents = stub.contents
                let structuredJsonData = structuredJson(fromStub: contents)
                let json = stub.name != "index.html" ? structuredJsonData.1 : finalStructuredJson(data: jsons)
                jsons.append(structuredJsonData)
                let page = generate(fromStub: contents, template: templateContents, json: json)
                page.write(toPath: PageGenerator.path + "/" + stub.name)
                addToRss(&rssContent, &siteMapContent, stub: contents)
            }
        }
        let rss = end(rss: rssContent)
        rss.write(toPath: PageGenerator.path + "/rss.xml")
        let siteMap = end(siteMap: siteMapContent)
        siteMap.write(toPath: PageGenerator.path + "/sitemap.xml")
    }

    func structuredJson(fromStub stub: String) -> (Date, String) {
        let dict = [String:String](uniqueKeysWithValues: stub.properties)
        let title = dict["WRITEIT_POST_NAME"] ?? "No Title"
        let desc = dict["WRITEIT_POST_SHORT_DESCRIPTION"] ?? "No Description"
        let sitemapDate = dict["WRITEIT_POST_SITEMAP_DATE"] ?? "No Date"
        let lastMod = dict["WRITEIT_POST_SITEMAP_DATE_LAST_MOD"] ?? "No Date"
        let html = dict["WRITEIT_POST_HTML_NAME"] ?? "No html"
        return (sitemapDate.sitemapDate, """
        {
        "@context": "https://schema.org",
        "@type": "BlogPosting",
        "mainEntityOfPage": {
          "@type": "WebPage",
          "@id": "https://swiftrocks.com/\(html)"
        },
        "image": [
          "https://swiftrocks.com/images/bg/swiftrockssocial.png"
        ],
        "datePublished": "\(sitemapDate)",
        "dateModified": "\(lastMod)",
        "author": {
          "@type": "Person",
          "name": "Bruno Rocha"
        },
         "publisher": {
          "@type": "Organization",
          "name": "SwiftRocks",
          "logo": {
            "@type": "ImageObject",
            "url": "https://swiftrocks.com/images/bg/swiftrockssocial.png"
          }
        },
        "headline": "\(title)",
            "abstract": "\(desc.replacingOccurrences(of: "\"", with: "'"))"
        }
        """)
    }

    func finalStructuredJson(data: [(Date, String)]) -> String {
        let jsons = data.sorted { $0.0 > $1.0 }.map { $0.1 }
        return "[" + jsons.joined(separator: ",") + "]"
    }

    func generate(fromStub stub: String, template: String, json: String) -> String {
        let identifier = "id=\"WRITEIT_DYNAMIC_CONTENT\">"
        guard let startingPos = template.range(of: identifier) else {
            print("Error: Could not locate the dynamic content div inside the template.")
            exit(1)
        }
        let prefix = String(template[template.startIndex..<startingPos.upperBound])
        let suffix = String(template[startingPos.upperBound...])
        let rawPage = prefix + stub + suffix
        var stubProperties = stub.properties
        stubProperties.append(("WRITEIT_POST_STRUCTURED_JSON", json))
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
        let sitemapDateLastMod = dict["WRITEIT_POST_SITEMAP_DATE_LAST_MOD"] ?? "No Date"
        let html = dict["WRITEIT_POST_HTML_NAME"] ?? "No html"

        let siteMapItem = """
        <url>
            <loc>https://swiftrocks.com/\(html)</loc>
            <lastmod>\(sitemapDateLastMod)</lastmod>
            <priority>0.80</priority>
        </url>
        <url>
            <loc>https://swiftrocks.com/\(html).html</loc>
            <lastmod>\(sitemapDateLastMod)</lastmod>
            <priority>0.80</priority>
        </url>

        """

        sitemap.append((sitemapDateLastMod.sitemapDate, siteMapItem))

        if dict["WRITEIT_POST_DONT_RSS"] == "true" {
            return
        }

        let date = sitemapDate.sitemapDate
        let rssFormatter = DateFormatter()
        rssFormatter.locale = Locale(identifier: "en_US_POSIX")
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

    var sitemapDate: Date {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter.date(from:self)!
    }
}
