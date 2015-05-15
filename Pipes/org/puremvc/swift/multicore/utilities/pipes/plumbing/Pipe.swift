//
//  Pipe.swift
//  PureMVC SWIFT/MultiCore Utility – Pipes
//
//  Copyright(c) 2015-2025 Saad Shams <saad.shams@puremvc.org>
//  Your reuse is governed by the Creative Commons Attribution 3.0 License
//

/**
Pipe.

This is the most basic `IPipeFitting`, 
simply allowing the connection of an output 
fitting and writing of a message to that output.
*/
public class Pipe: IPipeFitting {
    
    private var _output: IPipeFitting?
    
    /// Constructor.
    public init(output: IPipeFitting?=nil) {
        if(output != nil) {
            self.connect(output!)
        }
    }
    
    /**
    Connect another PipeFitting to the output.
    
    PipeFittings connect to and write to other 
    PipeFittings in a one-way, syncrhonous chain.
    
    :returns: Bool true if no other fitting was already connected.
    */
    public func connect(output: IPipeFitting) -> Bool {
        var success = false
        
        if(self.output == nil) {
            self.output = output
            success = true
        }
        return success
    }
    
    /**
    Disconnect the Pipe Fitting connected to the output.
    
    This disconnects the output fitting, returning a 
    reference to it. If you were splicing another fitting 
    into a pipeline, you need to keep (at least briefly) 
    a reference to both sides of the pipeline in order to 
    connect them to the input and output of whatever 
    fiting that you're splicing in.

    :returns: IPipeFitting the now disconnected output fitting
    */
    public func disconnect() -> IPipeFitting? {
        if let disconnectedFitting = self.output {
            self.output = nil
            return disconnectedFitting
        }
        return nil
    }
    
    /**
    Write the message to the connected output.
    
    :param: message the message to write
    :returns: Bool whether any connected downpipe outputs failed
    */
    public func write(message: IPipeMessage) -> Bool {
        if output != nil {
            output!.write(message)
            return true
        } else {
            return false
        }
    }
    
    /// Get or set the output
    public var output: IPipeFitting? {
        get { return _output }
        set { _output = newValue }
    }

}
