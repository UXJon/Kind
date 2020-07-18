import Foundation

///A Kind<T> gives a quick and simple way to extensibly express a cascading kind that is only associated with a particular type T.  This allows Kind<T>s to be defined in extensions for use with dot-syntax.  For example, a drag handle might be an `.upperLeftRect`, which is also a `.rectCorner` drag handle, which is also a `.rect` drag handle, and finally just a `.dragHandle`.  This allows you to define something (e.g. a style) at various levels of specificity, and then use the most specific kind which is available
public enum Kind<T>:Hashable,ExpressibleByStringLiteral {
    ///A kind without a fallback
    case id(String)
    ///Defines a kind and a fallback
    indirect case fallback(String, Kind<T>)
        
    ///Initialize with a kind id and fallback kind
    public init(_ id:String, fallback:Kind<T>){
        self = .fallback(id, fallback)
    }
    
    public init(_ id:String) {
        self = .id(id)
    }
    
    ///Initialize with a path that separates fallbacks using a given separator character (e.g. "upperLeftRect/rectCorner/rect/dragHandle")
    public init(path:String, separator:Character = "/") {
        guard let idx = path.firstIndex(of: separator) else {
            self = .id(path)
            return
        }
        let kind = String(path.prefix(upTo: idx))
        let rest = String(path.suffix(from: path.index(after: idx)))
        self = .fallback(kind, Kind<T>(path: rest))
    }
    
    public init(stringLiteral value: StringLiteralType) {
        self = .id(value)
    }
    
    ///The top-level id for this kind
    public var id:String {
        switch self{
        case .id(let kind): return kind
        case .fallback(let kind, _): return kind
        }
    }
    
    ///An array of id's for all fallbacks
    public var hierarchy:[String] {
        switch self {
        case .id(let kind): return [kind]
        case .fallback(let kind, let fallback): return [kind] + fallback.hierarchy
        }
    }
    
    ///Returns a path of ids separated by a given separator
    public func path(separator: Character = "/")->String {
        self.hierarchy.joined(separator: String(separator))
    }
    
    public var fallback:Kind<T>? {
        switch self {
        case .fallback(_, let fallback): return fallback
        case .id(_): return nil
        }
    }
    
    ///Finds the most specific value in the given dictionary using this kind as the key. It looks for the id in the given dictionary, then tries fallback ids if a value isn't found.
    public func value<V>(in dict:[Kind<T>:V]) -> V? {
        return dict[self] ?? self.fallback?.value(in: dict)
    }
    
    
    public func value<V>(in dict:[String:V]) -> V? {
        return dict[self.id] ?? self.fallback?.value(in: dict)
    }
    
    ///Two Kinds are equal if the ids are equal (fallbacks are not considered)
    public static func == (lhs:Kind<T>, rhs:Kind<T>)->Bool {
        return lhs.id == rhs.id
    }
    
    ///The hash only uses the id, since fallbacks are not considered in equality
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
        
}

extension Kind:CustomStringConvertible {
    public var description: String {
        return self.path()
    }
}

extension Kind:CustomDebugStringConvertible {
    public var debugDescription: String {
        return "Kind<\(T.self)>(\(self.path()))"
    }
}

extension Dictionary where Key == String {
    subscript<T>(_ kind:Kind<T>)->Value? {
        get{
            if let value = self[kind.id] {
                return value
            }
            guard let fallback = kind.fallback else {return nil}
            return self[fallback]
        }
        set{
            self[kind.id] = newValue
        }
    }
}
