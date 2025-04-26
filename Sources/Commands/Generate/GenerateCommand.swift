import ArgumentParser
import Foundation

enum GenerateError: LocalizedError {
    case noSiteData(String)
    case noPageTemplate(String)
    case noStubs(String)
    case noDynamicDiv(String)

    var errorDescription: String? {
        switch self {
        case .noSiteData(let path):
            return "Site data file not found! (\(path))"
        case .noPageTemplate(let path):
            return "Page template file not found! (\(path))"
        case .noStubs(let folder):
            return "There are no stubs to generate files from in the provided folder (\(folder))."
        case .noDynamicDiv(let path):
            return
                "Could not locate the dynamic content div inside the provided template. (\(path))"
        }
    }
}

struct Generate: ParsableCommand {
    @Option(help: "The path to the file containing information about the website.")
    var siteData: String = "./writeit_data.json"

    @Option(help: "The path to the page template .html file.")
    var pageTemplate: String = "./writeit_page_template.html"

    @Option(help: "The path to the folder where the stubs are stored.")
    var stubsFolder: String = "./writeit_stubs"

    //    @Option(help: "Enable verbose logging.")
    //    var verbose: Bool = false

    func run() throws {
        let siteData = File(filePath: siteData)
        let pageTemplate = File(filePath: pageTemplate)
        try GenerateRunner(
            siteData: siteData,
            pageTemplate: pageTemplate,
            stubsFolderPath: URL(filePath: stubsFolder).absoluteURL.path()
        ).run()
    }
}
