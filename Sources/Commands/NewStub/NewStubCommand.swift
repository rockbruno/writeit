import ArgumentParser
import Foundation

enum NewStubError: LocalizedError {
    case noStubTemplate(String)
    case noStubFolder(String)

    var errorDescription: String? {
        switch self {
        case .noStubTemplate(let path):
            return "Stub template file not found! (\(path))"
        case .noStubFolder(let path):
            return "The provided stubs folder doesn't seem to exist! (\(path))"
        }
    }
}

struct New: ParsableCommand {

    @Option(help: "The path to the stub template .html file.")
    var stubTemplate: String = "./writeit_stub_template.html"

    @Option(help: "The path to the folder where the stub should be stored.")
    var stubsFolder: String = "./writeit_stubs"

    //    @Option(help: "Enable verbose logging.")
    //    var verbose: Bool = false

    func run() throws {
        let stubTemplate = File(filePath: stubTemplate)
        try NewStubRunner(
            stubTemplate: stubTemplate,
            stubsFolderPath: URL(filePath: stubsFolder).absoluteURL.path()
        ).run()
    }
}
