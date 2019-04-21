import XCTest

final class StubGeneratorTests: XCTestCase {

    func testStubNaming() {
        let generator = StubGenerator()
        let postName = "My Post, super cool"
        XCTAssertEqual(generator.generateFileName(forPostName: postName), "my-post-super-cool")
    }

    func testStubGeneration() {
        let generator = StubGenerator()
        var stubTemplate = """
        <!--WRITEIT_POST_NAME-->
        <p>Woohoo! $WRITEIT_POST_NAME WRITEIT_POST_NAME</p>
        """
        let fakeName = "My Post"
        generator.add(value: fakeName, key: "WRITEIT_POST_NAME", toStub: &stubTemplate)
        XCTAssertEqual(stubTemplate, "<!--WRITEIT_POST_NAME=My Post-->\n<p>Woohoo! $WRITEIT_POST_NAME WRITEIT_POST_NAME</p>")
    }

    func testStubCustomPropertyParsing() {
        let stubTemplate = """
        <!--WRITEIT_POST_NAME-->
        <!--b-->
        <!--WRITEIT_POST_BLA-->
        <!-- WRITEIT_POST_BLA2--><!--WRITEIT_POST_BLA3-->
        """
        let result = StubGenerator.customProperties(fromStub: stubTemplate)
        XCTAssertEqual(result, ["WRITEIT_POST_NAME", "WRITEIT_POST_BLA"])
    }
}
