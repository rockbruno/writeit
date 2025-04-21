import Foundation
import os.log

struct StubGenerator {

    let stubTemplate: File
    let stubsFolderPath: String
    let verbose: Bool // FIXME: to introduce w/ a logger

    init(
        stubTemplate: File,
        stubsFolderPath: String,
        verbose: Bool
    ) throws {
        guard stubTemplate.exists else {
            throw NewStubError.noStubTemplate
        }
        self.stubTemplate = stubTemplate
        self.stubsFolderPath = stubsFolderPath
        self.verbose = verbose
    }

    func run() throws {
        let templateContents = try stubTemplate.contents
        let customPropertyNames = getCustomProperties(fromStubContents: templateContents)
        let customPropertyValues: [String] = customPropertyNames.map {
            print("Value for \($0): ", terminator: "")
            return readLine() ?? ""
        }
        print("Name of the new post: ", terminator: "")
        let name = readLine() ?? ""
        let fileName = generateFileName(forPostName: name)
        let propertyNames = [
            Stub.Keys.title.rawValue,
            Stub.Keys.htmlName.rawValue
        ] + customPropertyNames
        let propertyValues = [name, fileName] + customPropertyValues
        let properties = zip(propertyNames, propertyValues)
        var stub = """

        <!--\(Stub.Keys.title.rawValue)-->
        <!--\(Stub.Keys.htmlName.rawValue)-->


        """ + templateContents
        properties.forEach {
            set(value: $0.1, forPropertyKey: $0.0, inStub: &stub)
        }
        try File.write(
            contents: stub,
            toPath: stubsFolderPath + "/" + fileName + ".html"
        )
    }

    func generateFileName(forPostName name: String) -> String {
        var validSet = CharacterSet.alphanumerics
        validSet.insert(" ")
        let alphaOnly = name.components(separatedBy: validSet.inverted).joined()
        return alphaOnly.lowercased().replacingOccurrences(of: " ", with: "-")
    }

    func getCustomProperties(fromStubContents contents: String) -> [String] {
        return contents.components(separatedBy: "\n").compactMap {
            guard $0.hasPrefix("<!--WRITEIT_POST") && $0.hasSuffix("-->") else {
                return nil
            }
            return $0.components(separatedBy: "<!--")
                     .last?
                     .components(separatedBy: "-->")
                     .first
        }
    } // FIXME: Move?

    func set(value: String, forPropertyKey key: String, inStub stub: inout String) {
        stub = stub.replacingOccurrences(
            of: "<!--\(key)-->",
            with: "<!--\(key)=\(value)-->"
        )
    }
}
