import Foundation

struct File: Hashable {

    static let siteData = File(filePath: "./writeit_data.txt")

    let path: String
    var name: String {
        return (path as NSString).lastPathComponent
    }

    var contents: String {
        get throws {
            return try String(contentsOfFile: path, encoding: .utf8)
        }
    }

    var exists: Bool {
        return FileManager.fileExists(atPath: path)
    }

    init(filePath: String) {
        self.path = filePath
    }

    static func write(contents: String, toPath path: String) throws {
        try contents.write(
            toFile: path,
            atomically: false,
            encoding: .utf8
        )
    }
}
