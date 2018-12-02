import Foundation

final class StubGenerator {

    static let path = "./writeit-stubs"

    init() {}

    func run() {
        let templateContents = File.stubTemplate.contents
        print("Name of the new post: ", terminator: "")
        let name = readLine() ?? ""
        let fileName = generateFileName(forPostName: name)
        var stub = templateContents
        add(name: name, toStub: &stub)
        stub.write(toPath: StubGenerator.path + "/" + fileName + ".html")
    }

    func generateFileName(forPostName name: String) -> String {
        var validSet = CharacterSet.alphanumerics
        validSet.insert(" ")
        let alphaOnly = name.components(separatedBy: validSet.inverted).joined()
        return alphaOnly.lowercased().replacingOccurrences(of: " ", with: "-")
    }

    func add(name: String, toStub stub: inout String) {
        stub = stub.replacingOccurrences(of: "$writeit_post_name", with: name)
    }
}
