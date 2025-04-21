import Foundation
import ArgumentParser

enum NewStubError: LocalizedError {
    case noStubTemplate // FIXME print path

    var errorDescription: String? {
        switch self {
        case .noStubTemplate:
            return "Stub template file not found!"
        }
    }
}

struct NewStub: ParsableCommand {

    @Option(help: "The path to the stub template .html file.")
    var stubTemplate: String = "./writeit_stub_template.html"

    @Option(help: "The path to the folder where the stub should be stored.")
    var stubsFolder: String = "./writeit-stubs"

//    @Option(help: "Enable verbose logging.")
//    var verbose: Bool = false

    func run() throws {
        let stubTemplate = File(filePath: stubTemplate)
        try NewStubRunner(
            stubTemplate: stubTemplate,
            stubsFolderPath: stubsFolder
        ).run()
    }
}
