import Foundation

struct SiteData {
    let data: [String: String]

    init(data: [String: String]) {
        self.data = data
    }

    func get(_ key: String) -> String {
        guard let value = data[key] else {
            print("Error: Missing value for key '\(key)'")
            exit(1)
        }
        return value
    }
}

final class PageGenerator {

    var data: SiteData!

    init() {
    }

    func run() {
        let dataContents = File.siteData.contents
        let dataData = dataContents.components(separatedBy: "\n").map {
            $0.components(separatedBy: ":")
        }
        var dict = [String: String]()
        for a in dataData {
            dict[a[0]] = a[1]
        }
        self.data = SiteData(data: dict)


        let path = data.get("path")
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
                defer {
                    addToRss(&rssContent, &siteMapContent, stub: contents)
                }
                guard contents.externalURL == nil else {
                    return
                }
                let structuredJsonData = structuredJson(fromStub: contents)
                let json = stub.name != "index.html" ? structuredJsonData.1 : finalStructuredJson(data: jsons)
                jsons.append(structuredJsonData)
                let page = generate(
                    fromStub: contents,
                    template: templateContents,
                    json: json
                )
                page.write(toPath: path + "/" + stub.name)
            }
        }
        let rss = end(rss: rssContent)
        rss.write(toPath: path + "/rss.xml")
        let siteMap = end(siteMap: siteMapContent)
        siteMap.write(toPath: path + "/sitemap.xml")
    }

    func structuredJson(fromStub stub: String) -> (Date, String) {
        let dict = stub.properties
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
          "@id": "https://\(data.get("domain"))/\(html)"
        },
        "image": [
          "https://\(data.get("domain"))/images/thumbs/thumb.jpg"
        ],
        "datePublished": "\(sitemapDate)",
        "dateModified": "\(lastMod)",
        "author": {
          "@type": "Person",
          "name": "\(data.get("owner"))"
        },
         "publisher": {
          "@type": "Organization",
          "name": "\(data.get("name"))",
          "logo": {
            "@type": "ImageObject",
            "url": "https://\(data.get("domain"))/images/thumbs/thumb.jpg"
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

    func generate(
        fromStub stub: String,
        template: String,
        json: String
    ) -> String {
        let identifier = "id=\"WRITEIT_DYNAMIC_CONTENT\">"
        guard let startingPos = template.range(of: identifier) else {
            print("Error: Could not locate the dynamic content div inside the template.")
            exit(1)
        }
        let prefix = String(template[template.startIndex..<startingPos.upperBound])
        let suffix = String(template[startingPos.upperBound...])
        let rawPage = prefix + stub + suffix
        var stubProperties = stub.properties
        stubProperties["WRITEIT_POST_STRUCTURED_JSON"] = json

        let canonicalKey = "WRITEIT_POST_CANONICAL"
        if let canonicalUrl = stubProperties[canonicalKey] {
            stubProperties[canonicalKey] = "<link rel=\"canonical\" href=\"\(canonicalUrl)\" />"
        } else {
            stubProperties[canonicalKey] = ""
        }

        return rawPage.replace(properties: stubProperties)
    }

    func rssStart() -> String {
        return """
        <?xml version="1.0" encoding="utf-8"?>
        <rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
        <channel>
            <title>\(data.get("name"))</title>
            <description>\(data.get("description"))</description>
            <language>en-us</language>
            <copyright>\(data.get("copyright"))</copyright>
            <link>https://\(data.get("domain"))</link>
            <atom:link href="https://\(data.get("domain"))/rss.xml" rel="self" type="application/rss+xml"/>
        """
    }

    func addToRss(_ rss: inout [(Date, String)], _ sitemap: inout [(Date, String)], stub: String) {
        let dict = stub.properties

        let title = dict["WRITEIT_POST_NAME"] ?? "No Title"
        let sitemapDate = dict["WRITEIT_POST_SITEMAP_DATE"] ?? "No Date"
        let sitemapDateLastMod = dict["WRITEIT_POST_SITEMAP_DATE_LAST_MOD"] ?? "No Date"
        let html = dict["WRITEIT_POST_HTML_NAME"] ?? "No html"

        if stub.externalURL == nil {

            let siteMapItem = """
            <url>
                <loc>https://\(data.get("domain"))/\(html)</loc>
                <lastmod>\(sitemapDateLastMod)</lastmod>
                <priority>0.80</priority>
            </url>
            <url>
                <loc>https://\(data.get("domain"))/\(html).html</loc>
                <lastmod>\(sitemapDateLastMod)</lastmod>
                <priority>0.80</priority>
            </url>

            """

            sitemap.append((sitemapDateLastMod.sitemapDate, siteMapItem))

        }

        if dict["WRITEIT_POST_DONT_RSS"] == "true" {
            return
        }

        let date = sitemapDate.sitemapDate
        let rssFormatter = DateFormatter()
        rssFormatter.locale = Locale(identifier: "en_US_POSIX")
        rssFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss z"
        let rssDateString = rssFormatter.string(from: date)

        let rssLink: String = {
            if let externalURL = stub.externalURL {
                return externalURL
            } else {
                return "https://\(data.get("domain"))/\(html)"
            }
        }()

        let contents: String = {
            let contents = stub.replace(properties: stub.properties)
            if data.get("rss_swiftrocks_special") == "true" {
                return contents.rssForSwiftRocks
            } else {
                return contents
            }
        }()

        let item = """
        <item>
            <title>\(title)</title>
            <link>\(rssLink)</link>
            <guid>\(rssLink)</guid>
            <pubDate>\(rssDateString)</pubDate>
            <author>\(data.get("owner"))</author>
        <description><![CDATA[\(contents)]]></description>
        </item>

        """

        rss.append((date, item))
    }

    func end(rss: [(Date, String)]) -> String {
        let rssContent = rss.sorted { $0.0 > $1.0 }.map { $0.1 }
        var rss = rssStart()
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

struct Article: Codable, Hashable {
    let url: String
    let name: String
    let categories: [String]
}

extension String {
    var properties: [String: String] {
        let regex = try? NSRegularExpression(
            pattern: "<!--(WRITEIT_POST[^=\n]*)=(.*)-->",
            options: []
        )
        let matches = regex?.matches(
            in: self,
                    options: [],
                                     range: NSRange(location: 0, length: self.utf16.count))
        let arr = matches?.compactMap { match -> (String, String) in
            let nameRange = Range(match.range(at: 1), in: self)
            let valueRange = Range(match.range(at: 2), in: self)
            return (String(self[nameRange!]),
                    String(self[valueRange!]))
        } ?? []
        return [String:String](uniqueKeysWithValues: arr)
    }

    var externalURL: String? {
        return properties["WRITEIT_POST_EXTERNAL_LINK"]
    }

    var rssForSwiftRocks: String {
        let contents = self
        var idx = contents.startIndex
        var foundDiv = 0
        while idx != contents.endIndex {
            let after = contents.index(idx, offsetBy: 1)
            let after2 = contents.index(idx, offsetBy: 2)
            let after3 = contents.index(idx, offsetBy: 3)
            if contents[idx] == "<" &&
               contents[after] == "/" &&
               contents[after2] == "d" &&
               contents[after3] == "i" {
                foundDiv += 1
                if foundDiv == 3 {
                    let cutPoint = contents.index(idx, offsetBy: 6)
                    return String(contents[cutPoint...]).cutLastDiv
                }
            }
            idx = after
        }
        return contents
    }

    var cutLastDiv: String {
        var contents = self
        while contents.popLast() != "<" {
            continue
        }
        return contents
    }
}

extension String {
    func replace(properties: [String: String]) -> String {
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
