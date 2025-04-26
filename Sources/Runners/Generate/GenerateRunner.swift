import Foundation

final class GenerateRunner {

    let siteDataFile: File
    let siteData: SiteData
    let pageTemplate: File
    let templateContents: String
    let stubsFolderPath: String
    let rssBuilder: RSSBuilder
    let sitemapBuilder: SitemapBuilder

    init(
        siteData: File,
        pageTemplate: File,
        stubsFolderPath: String,
    ) throws {
        guard siteData.exists else {
            throw GenerateError.noSiteData(siteData.path)
        }
        guard pageTemplate.exists else {
            throw GenerateError.noPageTemplate(pageTemplate.path)
        }
        self.siteDataFile = siteData
        let siteData = try SiteData.create(fromFile: siteData)
        self.siteData = siteData
        self.pageTemplate = pageTemplate
        self.templateContents = try pageTemplate.contents
        self.stubsFolderPath = stubsFolderPath
        self.rssBuilder = RSSBuilder(siteData: siteData)
        self.sitemapBuilder = SitemapBuilder(siteData: siteData)
    }

    func run() throws {
        Logger.default("Using site data: \(siteDataFile.path)")
        Logger.default("Using page template: \(pageTemplate.path)")
        Logger.default("Using stubs folder path: \(stubsFolderPath)")
        print("")
        let stubs = try FileManager.files(
            atPath: stubsFolderPath,
            suffix: ".html"
        ).map {
            try Stub(file: $0, siteData: siteData)
        }
        guard stubs.isEmpty == false else {
            throw GenerateError.noStubs(stubsFolderPath)
        }
        Logger.info("Found \(stubs.count) stubs. Processing...")
        try stubs.forEach { stub in
            try autoreleasepool {
                if stub.externalLink != nil {
                    try handleExternalPost(stub)
                } else {
                    try handleRegularPost(stub)
                }
            }
        }
        Logger.info("Processing Sitemap...")
        try File.write(
            contents: sitemapBuilder.end(),
            toPath: siteData.outputPath + "/sitemap.xml"
        )
        Logger.info("Processing RSS...")
        try File.write(
            contents: rssBuilder.end(),
            toPath: siteData.outputPath + "/rss.xml"
        )
        Logger.success("Success! Results saved to \(siteData.outputPath)")
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
            throw GenerateError.noDynamicDiv(templateContents)
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
        let htmlName = stub.fileNameWithoutExtension
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
