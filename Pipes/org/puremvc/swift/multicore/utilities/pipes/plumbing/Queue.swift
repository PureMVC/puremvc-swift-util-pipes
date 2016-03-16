//
//  Queue.swift
//  PureMVC SWIFT/MultiCore Utility – Pipes
//
//  Copyright(c) 2015-2025 Saad Shams <saad.shams@puremvc.org>
//  Your reuse is governed by the Creative Commons Attribution 3.0 License
//

import Foundation

/**
Pipe Queue.

The Queue always stores inbound messages until you send it
a FLUSH control message, at which point it writes its buffer
to the output pipe fitting. The Queue can be sent a SORT
control message to go into sort-by-priority mode or a FIFO
control message to cancel sort mode and return the
default mode of operation, FIFO.

NOTE: There can effectively be only one Queue on a given
pipeline, since the first Queue acts on any queue control
message. Multiple queues in one pipeline are of dubious
use, and so having to name them would make their operation
more complex than need be.
*/
public class Queue: Pipe {
    
    private var mode = QueueControlMessage.SORT
    
    private var messages = [IPipeMessage]()
    
    // Concurrent queue for messagesQueue
    // for speed and convenience of running concurrently while reading, and thread safety of blocking while mutating
    private let messagesQueue: dispatch_queue_t = dispatch_queue_create("org.puremvc.pipes.Queue.messagesQueue", DISPATCH_QUEUE_CONCURRENT)
    
    
    /// Constructor.
    public override init(output: IPipeFitting?=nil) {
         super.init(output: output)
    }
    
    /**
    Handle the incoming message.

    Normal messages are enqueued.
    
    The FLUSH message type tells the Queue to write all
    stored messages to the ouptut PipeFitting, then
    return to normal enqueing operation.

    The SORT message type tells the Queue to sort all
    *subsequent* incoming messages by priority. If there
    are unflushed messages in the queue, they will not be
    sorted unless a new message is sent before the next FLUSH.
    Sorting-by-priority behavior continues even after a FLUSH,
    and can be turned off by sending a FIFO message, which is
    the default behavior for enqueue/dequeue.
    */
    public override func write(message: IPipeMessage) -> Bool {
        var success = true
        
        switch message.type {
        // Store normal messages
        case Message.NORMAL:
            store(message)
            
        // Flush the queue
        case QueueControlMessage.FLUSH:
            success = flush()
            
        // Put Queue into Priority Sort or FIFO mode
        // Subsequent messages written to the queue
        // will be affected. Sorted messages cannot
        // be put back into FIFO order!
        case QueueControlMessage.SORT,
             QueueControlMessage.FIFO:
            mode = message.type
        default:
            success = false
        }
        
        return success
    }
    
    /**
    Store a message.
    
    - parameter message: the IPipeMessage to enqueue.
    */
    func store(message: IPipeMessage) {
        dispatch_barrier_sync(messagesQueue) {
            self.messages.append(message)
            if self.mode == QueueControlMessage.SORT {
                self.messages.sortInPlace(self.sortMessagesByPriority)
            }
        }
    }
    
    /// Sort the Messages by priority.
    func sortMessagesByPriority(msgA: IPipeMessage, msgB: IPipeMessage) -> Bool {
        return msgA.priority < msgB.priority
    }
    
    /**
    Flush the queue.
    
    NOTE: This empties the queue.
    
    - returns: Bool true if all messages written successfully.
    */
    func flush() -> Bool { //read
        var success = true
        
        dispatch_sync(messagesQueue) {
            while (!self.messages.isEmpty) {
                let message = self.messages.removeAtIndex(0) as! Message
                let ok = self.output?.write(message)
                if ok != true {
                    success = false
                }
            }
        }
        return success
    }
    
}
