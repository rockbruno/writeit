import XCTest

final class PageGeneratorTests: XCTestCase {
    func testGeneration() {
        let generator = PageGenerator()
        let testStub = "<p>Woohoo!</p>"
        let testTemplate = "<body><div>Template, content: <div id=\"writeit_dynamic_content\"></div></div></body>"
        let result = generator.generate(fromStub: testStub, template: testTemplate)
        XCTAssertEqual(result, "<body><div>Template, content: <div id=\"writeit_dynamic_content\"><p>Woohoo!</p></div></div></body>")
    }
}
