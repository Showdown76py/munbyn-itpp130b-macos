import Foundation
import CBridge
public struct QueueSnapshot { public var location: String; public var uri: String
    public init(location: String,uri: String) { self.location = location; self.uri = uri }
}
public enum QueuePlan {
    public static let id = "MUNBYN_ITPP130B_Bluetooth"
    public static let display = "MUNBYN ITPP130B (Bluetooth)"
    public static let marker = "munbyn-itpp130b-bridge-v1"
    // same endpoint as the C-side inspection so reads and mutations never split
    public static var server: String { String(cString: mb_cups_host()) }
    public static let uri = "socket://127.0.0.1:19100/?contimeout=5&waiteof=true"
    public static func install(ppd: String,existing: QueueSnapshot?,server: String = QueuePlan.server) throws -> [String] {
        try validate(existing)
        guard ppd.hasPrefix("/"), !ppd.contains("\0"), ppd.hasSuffix(".ppd") else { throw BridgeError.invalid("Invalid bundled PPD path") }
        return ["-h",server,"-p",id,"-D",display,"-L",marker,"-v",uri,"-P",ppd,"-E","-o","printer-is-shared=false","-o","printer-error-policy=abort-job","-o","job-sheets-default=none","-o","PageSize=Label100x150"]
    }
    public static func uninstall(existing: QueueSnapshot?,server: String = QueuePlan.server) throws -> [String] {
        try validate(existing); return existing == nil ? [] : ["-h",server,"-x",id]
    }
    private static func validate(_ existing: QueueSnapshot?) throws {
        if let existing, existing.location != marker || existing.uri != uri {
            throw BridgeError.invalid("Queue identifier belongs to another configuration; refusing to modify it")
        }
    }
    public static func shellQuote(_ value: String) -> String { "'" + value.replacingOccurrences(of: "'",with: "'\\''") + "'" }
}
