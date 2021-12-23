import Foundation

final class StubGenerator {

    static let path = "/Users/rochab/Desktop/Other/rockbruno.github.io-private/writeit-stubs"

    static let postNameKey = "WRITEIT_POST_NAME"
    static let postHtmlNameKey = "WRITEIT_POST_HTML_NAME"

    init() {}

    func run() {
        let templateContents = File.stubTemplate.contents
        print("Name of the new post: ", terminator: "")
        let name = readLine() ?? ""
        let fileName = generateFileName(forPostName: name)
        let customPropertyNames = StubGenerator.customProperties(fromStub: templateContents)
        let customPropertyValues: [String] = customPropertyNames.map {
            print("Value for \($0): ", terminator: "")
            return readLine() ?? ""
        }
        let propertyNames = [StubGenerator.postNameKey, StubGenerator.postHtmlNameKey] + customPropertyNames
        let propertyValues = [name, fileName] + customPropertyValues
        let properties = zip(propertyNames, propertyValues)
        var stub = """

        <!--\(StubGenerator.postNameKey)-->
        <!--\(StubGenerator.postHtmlNameKey)-->


        """ + templateContents
        properties.forEach {
            add(value: $0.1, key: $0.0, toStub: &stub)
        }
        stub.write(toPath: StubGenerator.path + "/" + fileName + ".html")
    }

    func generateFileName(forPostName name: String) -> String {
        var validSet = CharacterSet.alphanumerics
        validSet.insert(" ")
        let alphaOnly = name.components(separatedBy: validSet.inverted).joined()
        return alphaOnly.lowercased().replacingOccurrences(of: " ", with: "-")
    }

    static func customProperties(fromStub stub: String) -> [String] {
        return stub.components(separatedBy: "\n").compactMap {
            guard $0.hasPrefix("<!--WRITEIT_POST") && $0.hasSuffix("-->") else {
                return nil
            }
            return $0.components(separatedBy: "<!--")
                     .last?
                     .components(separatedBy: "-->")
                     .first
        }
    }

    func add(value: String, key: String, toStub stub: inout String) {
        stub = stub.replacingOccurrences(of: "<!--\(key)-->", with: "<!--\(key)=\(value)-->")
    }
}
