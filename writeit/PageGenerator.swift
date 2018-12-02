import Foundation

final class PageGenerator {

    static let path = "./public"

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
        let identifier = "id=\"writeit_dynamic_content\">"
        guard let startingPos = template.range(of: identifier) else {
            print("Error: Could not locate the dynamic content div inside the template..")
            exit(1)
        }
        let prefix = String(template[template.startIndex..<startingPos.upperBound])
        let suffix = String(template[startingPos.upperBound...])
        return prefix + stub + suffix
    }
}

