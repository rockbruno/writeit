import Foundation

struct File: Hashable {

    static let pageTemplate = File(filePath: "./writeit_page_template.html")
    static let stubTemplate = File(filePath: "./writeit_stub_template.html")

    let path: String
    var name: String {
        return (path as NSString).lastPathComponent
    }

    var contents: String {
        do {
            return try String(contentsOfFile: path)
        } catch {
            print("Error: Failed to load contents of \(path)")
            exit(1)
        }
    }

    var exists: Bool {
        return FileManager.fileExists(atPath: path)
    }

    var hashValue: Int {
        return path.hashValue
    }

    public static func ==(lhs: File, rhs: File) -> Bool {
        return lhs.path == rhs.path
    }

    init(filePath: String) {
        self.path = filePath
    }
}

extension String {
    func write(toPath path: String) {
        do {
            try self.write(toFile: path, atomically: false, encoding: .utf8)
        } catch {
            print("Error: Failed to write to \(path). Reason: \(error.localizedDescription)")
            exit(1)
        }
    }
}
