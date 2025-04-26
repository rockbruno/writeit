import Foundation

enum ANSIColors: String {
    case black = "\u{001B}[0;30m"
    case red = "\u{001B}[0;31m"
    case green = "\u{001B}[0;32m"
    case yellow = "\u{001B}[0;33m"
    case blue = "\u{001B}[0;34m"
    case magenta = "\u{001B}[0;35m"
    case cyan = "\u{001B}[0;36m"
    case white = "\u{001B}[0;37m"
    case `default` = "\u{001B}[0;0m"
}

enum Logger {
    static func `default`(_ msg: String) {
        print(msg)
    }

    static func info(_ msg: String) {
        print("\(ANSIColors.cyan.rawValue)\(msg)\(ANSIColors.default.rawValue)")
    }

    static func success(_ msg: String) {
        print("\(ANSIColors.green.rawValue)\(msg)\(ANSIColors.default.rawValue)")
    }

    static func question(_ msg: String) {
        print("")
        print("\(ANSIColors.magenta.rawValue)\(msg)\(ANSIColors.default.rawValue)")
    }

    static func error(_ msg: String) {
        print("\(ANSIColors.red.rawValue)\(msg)\(ANSIColors.default.rawValue)")
    }
}
