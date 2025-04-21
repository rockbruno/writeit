import Foundation

final class PageGenerator {

    let siteData: SiteData
    let templateContents: String
    let stubsFolderPath: String
    let rssBuilder: RSSBuilder
    let sitemapBuilder: SitemapBuilder
    let verbose: Bool // Todo: implement some prints

    init(
        siteData: File,
        pageTemplate: File,
        stubsFolderPath: String,
        verbose: Bool
    ) throws {
        guard siteData.exists else {
            throw GenerateError.noSiteData
        }
        guard pageTemplate.exists else {
            throw GenerateError.noPageTemplate
        }
        let siteData = try SiteData(file: siteData)
        self.siteData = siteData
        self.templateContents = try pageTemplate.contents
        self.stubsFolderPath = stubsFolderPath
        self.verbose = verbose
        self.rssBuilder = RSSBuilder(siteData: siteData)
        self.sitemapBuilder = SitemapBuilder(siteData: siteData)
    }

    func run() throws {
        let stubs = try FileManager.files(
            atPath: stubsFolderPath,
            suffix: ".html"
        ).map {
            try Stub(file: $0, siteData: siteData)
        }
        guard stubs.isEmpty == false else {
            throw GenerateError.noStubs(stubsFolderPath)
        }
        try stubs.forEach { stub in
            try autoreleasepool {
                if stub.externalLink != nil {
                    try handleExternalPost(stub)
                } else {
                    try handleRegularPost(stub)
                }
            }
        }
        try File.write(
            contents: sitemapBuilder.end(),
            toPath: siteData.outputPath + "/sitemap.xml"
        )
        try File.write(
            contents: rssBuilder.end(),
            toPath: siteData.outputPath + "/rss.xml"
        )
    }

    func handleExternalPost(_ stub: Stub) throws {
        try rssBuilder.process(stub: stub)
    }

    func handleRegularPost(_ stub: Stub) throws {
        try rssBuilder.process(stub: stub)
        try sitemapBuilder.process(stub: stub)

        // Handle automatic structured JSON generation / injection
        let structuredJson = try getStructuredJson(
            for: stub,
            siteData: siteData
        )
        var rawProperties = stub.rawProperties
        rawProperties[Stub.Keys.structuredJson.rawValue] = structuredJson

        // Generate the final result
        let identifier = "id=\"WRITEIT_DYNAMIC_CONTENT\">"
        guard let startingPos = templateContents.range(of: identifier) else {
            throw GenerateError.noDynamicDiv
        }
        let prefix = String(
            templateContents[templateContents.startIndex..<startingPos.upperBound]
        )
        let suffix = String(templateContents[startingPos.upperBound...])
        let rawPage = prefix + stub.rawContents + suffix
        let page = Stub.resolveProperties(
            fromString: rawPage,
            rawProperties: rawProperties,
            siteData: siteData
        )

        try File.write(
            contents: page,
            toPath: siteData.outputPath + "/" + stub.fileName
        )
    }

    func getStructuredJson(
        for stub: Stub,
        siteData: SiteData
    ) throws -> String {
        if let structuredJson = stub.structuredJson {
            return structuredJson
        }
        let title = try stub.title
        let desc = try stub.description
        let sitemapDate = try stub.sitemapDateString
        let lastMod = try stub.sitemapDateLastMod
        let htmlName = try stub.htmlName
        return """
        {
        "@context": "https://schema.org",
        "@type": "BlogPosting",
        "mainEntityOfPage": {
          "@type": "WebPage",
          "@id": "https://\(siteData.domain)/\(htmlName)"
        },
        "image": [
          "https://\(siteData.domain)/\(siteData.thumbPath)"
        ],
        "datePublished": "\(sitemapDate)",
        "dateModified": "\(lastMod)",
        "author": {
          "@type": "Person",
          "name": "\(siteData.owner)"
        },
         "publisher": {
          "@type": "Organization",
          "name": "\(siteData.name)",
          "logo": {
            "@type": "ImageObject",
            "url": "https://\(siteData.domain)/\(siteData.thumbPath)"
          }
        },
        "headline": "\(title)",
            "abstract": "\(desc.replacingOccurrences(of: "\"", with: "'"))"
        }
        """
    }
}
