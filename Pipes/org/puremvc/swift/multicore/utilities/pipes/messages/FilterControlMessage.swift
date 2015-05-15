//
//  FilterControlMessage.swift
//  PureMVC SWIFT/MultiCore Utility – Pipes
//
//  Copyright(c) 2015-2025 Saad Shams <saad.shams@puremvc.org>
//  Your reuse is governed by the Creative Commons Attribution 3.0 License
//

/**
Filter Control Message.

A special message type for controlling the behavior of a Filter.

The `FilterControlMessage.SET_PARAMS` message type tells the Filter 
to retrieve the filter parameters object.

The `FilterControlMessage.SET_FILTER` message type tells the Filter 
to retrieve the filter function.

The `FilterControlMessage.BYPASS` message type tells the Filter 
that it should go into Bypass mode operation, passing all normal 
messages through unfiltered.

The `FilterControlMessage.FILTER` message type tells the Filter 
that it should go into Filtering mode operation, filtering all 
normal normal messages before writing out. This is the default 
mode of operation and so this message type need only be sent to 
cancel a previous `FilterControlMessage.BYPASS` message.

The Filter only acts on a control message if it is targeted 
to this named filter instance. Otherwise it writes the 
message through to its output unchanged.
*/
public class FilterControlMessage: Message {
    
    /// Message type base URI
    public override class var BASE: String { return Message.BASE + "filter-control/" }
    
    /// Set filter parameters.
    public class var SET_PARAMS: String { return FilterControlMessage.BASE + "setParams" }
    
    /// Set filter function.
    public class var SET_FILTER: String { return FilterControlMessage.BASE + "setFilter" }
    
    /// Toggle to filter bypass mode.
    public class var BYPASS: String { return FilterControlMessage.BASE + "bypass" }
    
    /// Toggle to filtering mode. (default behavior).
    public class var FILTER: String { return FilterControlMessage.BASE + "filter" }
    
    private var _name: String?
    
    private var _filter: ((message: IPipeMessage, params: Any?) -> Bool)?
    
    private var _params: Any?
    
    /// Constructor
    public init(type: String, name: String, filter: ((IPipeMessage, Any?) -> Bool)?=nil, params: Any?=nil) {
        super.init(type: type, header: nil, body: nil)
        self.name = name
        self.filter = filter
        self.params = params
    }
    
    /// Get or set the target filter name.
    public var name: String? {
        get { return _name }
        set { _name = newValue }
    }
    
    /// Get or set the filter function.
    public var filter: ((message: IPipeMessage, params: Any?) -> Bool)? {
        get { return _filter }
        set { _filter = newValue }
    }

    /// Get or set the parameters object.
    public var params: Any? {
        get { return _params }
        set { _params = newValue }
    }
}
