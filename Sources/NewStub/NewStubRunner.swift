import Foundation
import os.log

struct NewStubRunner {

    let stubTemplate: File
    let stubsFolderPath: String

    init(
        stubTemplate: File,
        stubsFolderPath: String
    ) throws {
        guard stubTemplate.exists else {
            throw NewStubError.noStubTemplate(stubTemplate.path)
        }
        guard FileManager.folderExists(atPath: stubsFolderPath) else {
            throw NewStubError.noStubFolder(stubsFolderPath)
        }
        self.stubTemplate = stubTemplate
        self.stubsFolderPath = stubsFolderPath
    }

    func run() throws {
        let templateContents = try stubTemplate.contents
        let customPropertyNames = Set(getCustomProperties(
            fromStubContents: templateContents
        ))
        var propertyValues = [String: String]()

        // Autofill sitemap properties
        let now = Stub.sitemapDateFormatter.string(from: .now)
        propertyValues[Stub.Keys.sitemapDate.rawValue] = now
        propertyValues[Stub.Keys.sitemapLastMod.rawValue] = now

        print("Type the title of the new post: ", terminator: "")
        let name = getAnswer()
        let fileName = generateFileName(forPostName: name)
        propertyValues[Stub.Keys.title.rawValue] = name

        // Don't duplicate data for things we already filled
        let remainingPropertiesToFill = customPropertyNames.filter {
            propertyValues[$0] == nil
        }

        for property in remainingPropertiesToFill.sorted() {
            print("Type the value for \(property): ", terminator: "")
            propertyValues[property] = getAnswer()
        }

        var stub = ""

        addPropertyIfNeeded(
            key: .title,
            properties: customPropertyNames,
            stub: &stub
        )
        addPropertyIfNeeded(
            key: .sitemapDate,
            properties: customPropertyNames,
            stub: &stub
        )
        addPropertyIfNeeded(
            key: .sitemapLastMod,
            properties: customPropertyNames,
            stub: &stub
        )

        stub += "\n" + templateContents

        propertyValues.forEach {
            set(value: $0.1, forPropertyKey: $0.0, inStub: &stub)
        }

        let resultPath = stubsFolderPath + "/" + fileName + ".html"
        try File.write(
            contents: stub,
            toPath: resultPath
        )

        print("Done! Result written to \(resultPath)")
    }

    private func addPropertyIfNeeded(key: Stub.Keys, properties: Set<String>, stub: inout String) {
        guard properties.contains(key.rawValue) == false else {
            return
        }
        stub += """
        <!--\(key.rawValue)-->

        """
    }

    private func generateFileName(forPostName name: String) -> String {
        var validSet = CharacterSet.alphanumerics
        validSet.insert(" ")
        let alphaOnly = name.components(separatedBy: validSet.inverted).joined()
        return alphaOnly.lowercased().replacingOccurrences(of: " ", with: "-")
    }

    private func getCustomProperties(fromStubContents contents: String) -> [String] {
        return contents.components(separatedBy: "\n").compactMap {
            guard $0.hasPrefix("<!--WRITEIT_POST") && $0.hasSuffix("-->") else {
                return nil
            }
            return $0.components(separatedBy: "<!--")
                .last?
                .components(separatedBy: "-->")
                .first
        }
    }

    private func getAnswer() -> String {
        guard let result = readLine(), result.isEmpty == false else {
            print("Answers cannot be empty. Please try again: ", terminator: "")
            return getAnswer()
        }
        return result
    }

    private func set(
        value: String,
        forPropertyKey key: String,
        inStub stub: inout String
    ) {
        stub = stub.replacingOccurrences(
            of: "<!--\(key)-->",
            with: "<!--\(key)=\(value)-->"
        )
    }
}
