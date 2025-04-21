import Foundation

struct File: Hashable {

    let path: String

    var name: String {
        return url.lastPathComponent
    }

    var contents: String {
        get throws {
            return try String(contentsOfFile: path, encoding: .utf8)
        }
    }

    var exists: Bool {
        return FileManager.fileExists(atPath: path)
    }

    var url: URL {
        return URL(filePath: path)
    }

    init(filePath: String) {
        self.path = URL(filePath: filePath).absoluteURL.path()
    }

    static func write(contents: String, toPath path: String) throws {
        try contents.write(
            toFile: path,
            atomically: false,
            encoding: .utf8
        )
    }
}
