import Foundation

// not a fancy logger, but hey ¯\_(ツ)_/¯
public class Logger {

    public static func log(tag: String, _ message: String) {
        print("[\(tag)]: \(message)")
    }

    public static func error(tag: String, _ message: String) {
        print("[\(tag)] - ERROR: \(message)")
    }
}
