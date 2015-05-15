//
//  TeeMerge.swift
//  PureMVC SWIFT/MultiCore Utility – Pipes
//
//  Copyright(c) 2015-2025 Saad Shams <saad.shams@puremvc.org>
//  Your reuse is governed by the Creative Commons Attribution 3.0 License
//

/**
Merging Pipe Tee.

Writes the messages from multiple input pipelines into
a single output pipe fitting.
*/
public class TeeMerge: Pipe {
    
    /**
    Constructor.
    
    Create the TeeMerge and the two optional constructor inputs.
    This is the most common configuration, though you can connect
    as many inputs as necessary by calling `connectInput`
    repeatedly.
    
    Connect the single output fitting normally by calling the
    `connect` method, as you would with any other IPipeFitting.
    */
    public init(input1: IPipeFitting?=nil, input2: IPipeFitting?=nil) {
        super.init()
        
        if input1 != nil { connectInput(input1!) }
        if input2 != nil { connectInput(input2!) }
    }
    
    /**
    Connect an input IPipeFitting.
    
    NOTE: You can connect as many inputs as you want
    by calling this method repeatedly.
    
    :param: input the IPipeFitting to connect for input.
    */
    public func connectInput(input: IPipeFitting) -> Bool {
        return input.connect(self)
    }
    
}
