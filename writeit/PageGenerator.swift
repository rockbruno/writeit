import Foundation

final class PageGenerator {

    static var path = "./public"

    init() {}
    func run() {
        let templateContents = File.pageTemplate.contents
        let stubs = FileManager.files(atPath: StubGenerator.path, suffix: ".html")
        guard stubs.isEmpty == false else {
            print("Error: There are no stubs to generate files from in this folder.")
            exit(1)
        }
        stubs.forEach { stub in
            autoreleasepool {
                let page = generate(fromStub: stub.contents, template: templateContents)
                page.write(toPath: PageGenerator.path + "/" + stub.name)
            }
        }
    }

    func generate(fromStub stub: String, template: String) -> String {
        let identifier = "id=\"WRITEIT_DYNAMIC_CONTENT\">"
        guard let startingPos = template.range(of: identifier) else {
            print("Error: Could not locate the dynamic content div inside the template.")
            exit(1)
        }
        let prefix = String(template[template.startIndex..<startingPos.upperBound])
        let suffix = String(template[startingPos.upperBound...])
        let rawPage = prefix + stub + suffix
        let regex = try? NSRegularExpression(
            pattern: "<!--(WRITEIT_POST[^=\n]*)=(.*)-->",
            options: []
        )
        let matches = regex?.matches(in: stub,
                                     options: [],
                                     range: NSRange(location: 0, length: stub.utf16.count))
        let stubProperties = matches?.compactMap { match -> (String, String) in
            let nameRange = Range(match.range(at: 1), in: stub)
            let valueRange = Range(match.range(at: 2), in: stub)
            return (String(stub[nameRange!]),
                    String(stub[valueRange!]))
        } ?? []
        var page = rawPage
        stubProperties.forEach {
            page = page.replacingOccurrences(of: "$\($0.0)", with: $0.1)
        }
        return page
    }
}
