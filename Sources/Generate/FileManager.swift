import Foundation

struct FileManager {
    static func fileExists(atPath path: String) -> Bool {
        var isDir: ObjCBool = false
        guard Foundation.FileManager.default.fileExists(
            atPath: path,
            isDirectory: &isDir
        ) else {
            return false
        }
        return isDir.boolValue == false
    }

    static func files(atPath path: String, suffix: String) -> [File] {
        var result = [String]()
        let fileManager = Foundation.FileManager.default
        if let paths = fileManager.subpaths(atPath: path) {
            let suffixPaths = paths
            for subpath in suffixPaths {
                var isDir: ObjCBool = false
                let fullPath = (path as NSString).appendingPathComponent(subpath)
                guard fileManager.fileExists(
                    atPath: fullPath,
                    isDirectory: &isDir
                ) else {
                    continue
                }
                guard fullPath.hasSuffix(suffix) else {
                    continue
                }
                guard isDir.boolValue == false else {
                    continue
                }
                result.append(fullPath)
            }
        }
        return result.map(File.init)
    }
}
