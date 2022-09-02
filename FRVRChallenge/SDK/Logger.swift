import Foundation

class Logger {

    static func log(tag: String, _ message: String) {
        print("[\(tag)]: \(message)") // not a fancy log, but hey ¯\_(ツ)_/¯
    }
}
