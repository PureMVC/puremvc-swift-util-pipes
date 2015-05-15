//
//  QueueControlMessage.swift
//  PureMVC SWIFT/MultiCore Utility – Pipes
//
//  Copyright(c) 2015-2025 Saad Shams <saad.shams@puremvc.org>
//  Your reuse is governed by the Creative Commons Attribution 3.0 License
//

/**
Queue Control Message.

A special message for controlling the behavior of a Queue.

When written to a pipeline containing a Queue, the type 
of the message is interpreted and acted upon by the Queue.

Unlike filters, multiple serially connected queues aren't 
very useful and so they do not require a name. If multiple 
queues are connected serially, the message will be acted 
upon by the first queue only.
*/
public class QueueControlMessage: Message {
    
    /// Base namespace for the QueueControlMessage
    public override class var BASE: String { return Message.BASE + "queue/" }
    
    /// Flush the queue.
    public class var FLUSH: String { return QueueControlMessage.BASE + "flush" }
    
    /// Toggle to sort-by-priority operation mode.
    public class var SORT: String { return QueueControlMessage.BASE + "sort" }
    
    /// Toggle to FIFO operation mode (default behavior).
    public class var FIFO: String { return QueueControlMessage.BASE + "FIFO" }
    
    /// Constructor
    public init(type: String) {
        super.init(type: type, header: nil, body: nil)
    }
    
}
