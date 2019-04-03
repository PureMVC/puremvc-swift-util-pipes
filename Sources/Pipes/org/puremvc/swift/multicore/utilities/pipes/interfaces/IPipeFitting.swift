//
//  IPipeFitting.swift
//  PureMVC SWIFT/MultiCore Utility – Pipes
//
//  Copyright(c) 2015-2025 Saad Shams <saad.shams@puremvc.org>
//  Your reuse is governed by the Creative Commons Attribution 3.0 License
//

/**
Pipe Fitting Interface.

An `IPipeFitting` can be connected to other
`IPipeFittings`, forming a Pipeline.
`IPipeMessages` are written to one end of a
Pipeline by some client code. The messages are then
transfered in synchronous fashion from one fitting to the next.
*/

public protocol IPipeFitting {
    
    /**
    Connect another Pipe Fitting to the output.
    
    Fittings connect and write to
    other fittings in a one way syncrhonous 
    chain, as water typically flows one direction 
    through a physical pipe.
    
    - returns: Boolean true if no other fitting was already connected.
    */
    func connect(_ output: IPipeFitting) -> Bool
    
    /**
    Disconnect the Pipe Fitting connected to the output.

    This disconnects the output fitting, returning a 
    reference to it. If you were splicing another fitting 
    into a pipeline, you need to keep (at least briefly) 
    a reference to both sides of the pipeline in order to 
    connect them to the input and output of whatever 
    fiting that you're splicing in.
    
    - returns: IPipeFitting the now disconnected output fitting
    */
    func disconnect() -> IPipeFitting?
    
    /**
    Write the message to the output Pipe Fitting.
    
    There may be subsequent filters and tees 
    (which also implement this interface), that the 
    fitting is writing to, and so a message 
    may branch and arrive in different forms at 
    different endpoints.
	 	
    If any fitting in the chain returns false 
    from this method, then the client who originally 
    wrote into the pipe can take action, such as 
    rolling back changes.
    */
    func write(_ message: IPipeMessage) -> Bool
}
