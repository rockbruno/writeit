import Foundation
import ArgumentParser

enum GenerateError: LocalizedError {
    case noSiteData // FIXME print path
    case noPageTemplate
    case noStubs(String)
    case noDynamicDiv

    var errorDescription: String? {
        switch self {
        case .noSiteData:
            return "Site data file not found!"
        case .noPageTemplate:
            return "Page template file not found!"
        case .noStubs(let folder):
            return "There are no stubs to generate files from in the provided folder (\(folder))."
        case .noDynamicDiv:
            return "Could not locate the dynamic content div inside the template."
        }
    }
}

struct Generate: ParsableCommand {
    @Option(help: "The path to the file containing information about the website.")
    var siteData: String = "./writeit_data.txt"
    
    @Option(help: "The path to the page template .html file.")
    var pageTemplate: String = "./writeit_page_template.html"

    @Option(help: "The path to the folder where the stubs are stored.")
    var stubsFolder: String = "./writeit-stubs"

    @Option(help: "Enable verbose logging.")
    var verbose: Bool = false

    func run() throws {
        let siteData = File(filePath: siteData)
        let pageTemplate = File(filePath: pageTemplate)
        try PageGenerator(
            siteData: siteData,
            pageTemplate: pageTemplate,
            stubsFolderPath: stubsFolder,
            verbose: verbose
        ).run()
    }
}

@main
struct WriteIt: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Static website generator by Bruno Rocha (rockbruno.com)",
        subcommands: [Generate.self, NewStub.self],
        defaultSubcommand: Generate.self
    )
}
