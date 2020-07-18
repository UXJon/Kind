# Kind

A `Kind<T>` gives a quick and simple way to extensibly express a cascading kind that is only associated with a particular type T. Kinds have a string Id and can optionally fallback to another kind.  This allows you to define something (e.g. a style) at various levels of specificity, and then use the most specific kind which is available.

Extensions can be used to define kinds for a particular type which can be accessed via dot-syntax.

As a specific example:
```
struct DragHandle {
	var kind:Kind<DragHandle> = .free
	///Other properties
}

extension Kind where T == DragHandle {
	static var free:Kind<DragHandle> = "general"
	static var rect:Kind<DragHandle> = .fallback("rect", .free)
	static var rectCorner:Kind<DragHandle> = .fallback("rectCorner", .rect)
	
	static var upperLeft:Kind<DragHandle> = .fallback("upperLeft",.rectCorner)
	//...
}
```

The `value(in:)` function can be used to get the most specific value associated with a kind in a given dictionary. It looks for the id in the given dictionary, then tries fallback ids if a value isn't found.
```
var styles:[Kind<DragHandle>: HandleStyle] = //...

let style:HandleStyle = kind.value(in: styles)
```

