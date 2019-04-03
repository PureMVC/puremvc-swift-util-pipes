//
//  Message.swift
//  PureMVC SWIFT/MultiCore Utility – Pipes
//
//  Copyright(c) 2015-2025 Saad Shams <saad.shams@puremvc.org>
//  Your reuse is governed by the Creative Commons Attribution 3.0 License
//

/**
Pipe Message.

Messages travelling through a Pipeline can 
be filtered, and queued. In a queue, they may 
be sorted by priority. Based on type, 
they may used as control messages to modify the 
behavior of filter or queue fittings connected 
to the pipleline into which they are written.
*/
public class Message: IPipeMessage {
    
    /// High priority Messages can be sorted to the front of the queue
    public class var PRIORITY_HIGH: Int { return 1 }
    
    /// Medium priority Messages are the default
    public class var PRIORITY_MED: Int { return 5 }
    
    /// Low priority Messages can be sorted to the back of the queue
    public class var PRIORITY_LOW: Int { return 10 }
    
    /// Base namespace for the message
    public class var BASE: String { return "http://puremvc.org/namespaces/pipes/messages/" }
    
    /// Normal Message type
    public class var NORMAL: String { return Message.BASE + "normal/" }
    
    // Messages in a queue can be sorted by priority.
    private var _priority: Int = 5
    
    // Messages can be handled differently according to type
    private var _type: String!
    
    // Header properties describe any meta data about the message for the recipient
    private var _header: Any?
    
    // Body of the message is the precious cargo
    private var _body: Any?
    
    /// Constructor
    public init(type: String, header: Any?=nil, body: Any?=nil, priority:Int = 5) {
        self.type = type
        self.header = header
        self.body = body
        self.priority = priority
    }
    
    /// Get Set the type of this message
    public var type: String {
        get { return _type }
        set { _type = newValue }
    }
    
    /// Get Set the priority of this message
    public var priority: Int {
        get { return _priority }
        set { _priority = newValue }
    }
    
    /// Get Set the header of this message
    public var header: Any? {
        get { return _header }
        set { _header = newValue }
    }
    
    /// Get Set the body of this message
    public var body: Any? {
        get { return _body }
        set { _body = newValue }
    }
    
}
