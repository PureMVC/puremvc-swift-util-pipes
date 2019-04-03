//
//  IPipeAware.swift
//  PureMVC SWIFT/MultiCore Utility – Pipes
//
//  Copyright(c) 2015-2025 Saad Shams <saad.shams@puremvc.org>
//  Your reuse is governed by the Creative Commons Attribution 3.0 License
//

/**
Pipe Aware interface.

Can be implemented by any PureMVC Core that wishes
to communicate with other Cores using the Pipes
utility.
*/

public protocol IPipeAware {
    
    /**
    Connect input Pipe Fitting.
    
    - parameter name: name of the input pipe
    - parameter pipe: input Pipe Fitting
    */
    func acceptInputPipe(_ name: String, pipe: IPipeFitting)
    
    /**
    Connect output Pipe Fitting.
    
    - parameter name: name of the input pipe
    - parameter pipe: output Pipe Fitting
    */
    func acceptOutputPipe(_ name: String, pipe: IPipeFitting)
    
}
