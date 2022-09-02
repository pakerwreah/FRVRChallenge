import Foundation

public class Logger {

    public static func log(tag: String, _ message: String) {
        print("[\(tag)]: \(message)") // not a fancy log, but hey ¯\_(ツ)_/¯
    }
}
