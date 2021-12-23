import XCTest

final class PageGeneratorTests: XCTestCase {
    func testGeneration() {
        let generator = PageGenerator()
        let testStub = "<!--WRITEIT_POST_NAME=My Page--><p>Woohoo! $WRITEIT_POST_NAME</p>"
        let testTemplate = """
        <meta name="title" content="$WRITEIT_POST_NAME">
        <body><div>Template, $WRITEIT_POST_NAME content:
        <div id=\"WRITEIT_DYNAMIC_CONTENT\"></div>
        </div></body>
        """
        let result = generator.generate(
            fromStub: testStub,
            template: testTemplate,
            json: ""
        )
        XCTAssertEqual(result, """
        <meta name="title" content="My Page">
        <body><div>Template, My Page content:
        <div id=\"WRITEIT_DYNAMIC_CONTENT\"><!--WRITEIT_POST_NAME=My Page--><p>Woohoo! My Page</p></div>
        </div></body>
        """)
    }
}
