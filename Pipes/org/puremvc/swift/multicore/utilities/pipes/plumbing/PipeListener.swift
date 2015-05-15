//
//  PipeListener.swift
//  PureMVC SWIFT/MultiCore Utility – Pipes
//
//  Copyright(c) 2015-2025 Saad Shams <saad.shams@puremvc.org>
//  Your reuse is governed by the Creative Commons Attribution 3.0 License
//

/**
Pipe Listener.

Allows a class that does not implement `IPipeFitting` to
be the final recipient of the messages in a pipeline.

`@see Junction`
*/
public class PipeListener: IPipeFitting {
    
    weak private var context: AnyObject?
    
    private var listener: IPipeMessage -> ()
    
    /// constructor
    public init(context: AnyObject, listener: IPipeMessage -> ()) {
        self.context = context
        self.listener = listener
    }
    
    /// Can't connect anything beyond this.
    public func connect(output: IPipeFitting) -> Bool {
        return false
    }
    
    /// Can't disconnect since you can't connect, either.
    public func disconnect() -> IPipeFitting? {
        return nil
    }
    
    /// Write the message to the listener
    public func write(message: IPipeMessage) -> Bool {
        self.listener(message)
        return true
    }

}
