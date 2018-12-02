import XCTest

final class StubGeneratorTests: XCTestCase {

    func testStubNaming() {
        let generator = StubGenerator()
        let postName = "My Post, super cool"
        XCTAssertEqual(generator.generateFileName(forPostName: postName), "my-post-super-cool")
    }

    func testStubGeneration() {
        let generator = StubGenerator()
        var stubTemplate = "<p>Woohoo! $writeit_post_name</p>"
        let fakeName = "My Post"
        generator.add(name: fakeName, toStub: &stubTemplate)
        XCTAssertEqual(stubTemplate, "<p>Woohoo! My Post</p>")
    }
}
