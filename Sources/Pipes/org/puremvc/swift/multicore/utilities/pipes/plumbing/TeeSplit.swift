//
//  TeeSplit.swift
//  PureMVC SWIFT/MultiCore Utility – Pipes
//
//  Copyright(c) 2015-2025 Saad Shams <saad.shams@puremvc.org>
//  Your reuse is governed by the Creative Commons Attribution 3.0 License
//

import Foundation

/**
Splitting Pipe Tee.

Writes input messages to multiple output pipe fittings.
*/
public class TeeSplit: IPipeFitting {
    
    private var outputs = [IPipeFitting]()
    
    // Concurrent queue for messagesQueue
    // for speed and convenience of running concurrently while reading, and thread safety of blocking while mutating
    private var outputsQueue = DispatchQueue(label: "org.puremvc.pipes.TeeSplit.outputsQueue", attributes: DispatchQueue.Attributes.concurrent)
    
    /**
    Constructor.
    
    Create the TeeSplit and connect the up two optional outputs.
    This is the most common configuration, though you can connect
    as many outputs as necessary by calling `connect`.
    */
    public init(output1: IPipeFitting?=nil, output2: IPipeFitting?=nil) {
        if output1 != nil { _ = connect(output1!) }
        if output2 != nil { _ = connect(output2!) }
    }
    
    /**
    Connect the output IPipeFitting.
    
    NOTE: You can connect as many outputs as you want
    by calling this method repeatedly.
    
    - parameter output: the IPipeFitting to connect for output.
    */
    public func connect(_ output: IPipeFitting) -> Bool {
        outputsQueue.sync(flags: .barrier, execute: {
            self.outputs.append(output)
        })
        return true
    }
    
    /**
    Disconnect the most recently connected output fitting. (LIFO)
    
    To disconnect all outputs, you must call this
    method repeatedly untill it returns nil.
    
    - parameter output: the IPipeFitting to connect for output.
    */
    public func disconnect() -> IPipeFitting? {
        var pipe: IPipeFitting?
        outputsQueue.sync(flags: .barrier, execute: {
            pipe = !self.outputs.isEmpty ? self.outputs.remove(at: self.outputs.count - 1) : nil
        })
        return pipe
    }
    
    /**
    Disconnect a given output fitting.
    
    If the fitting passed in is connected
    as an output of this `TeeSplit`, then
    it is disconnected and the reference returned.
    
    If the fitting passed in is not connected as an
    output of this `TeeSplit`, then `nil`
    is returned.
    
    - parameter output: the IPipeFitting to connect for output.
    */
    public func disconnectFitting(_ target: IPipeFitting) -> IPipeFitting? {
        var removed: IPipeFitting?
        outputsQueue.sync(flags: .barrier, execute: {
            for (index, _) in self.outputs.enumerated() {
                let output = self.outputs[index]
                if output as! Pipe === target as! Pipe {
                    self.outputs.remove(at: index)
                    removed = output
                }
            }
        })
        return removed
    }
    
    /**
    Write the message to all connected outputs.
    
    Returns false if any output returns false,
    but all outputs are written to regardless.
    
    - parameter message: the message to write
    - returns: Boolean whether any connected outputs failed
    */
    public func write(_ message: IPipeMessage) -> Bool {
        var success = true
        outputsQueue.sync {
            for output in self.outputs {
                if !(output.write(message)) {
                    success = false
                }
            }
        }
        return success
    }
    
}
