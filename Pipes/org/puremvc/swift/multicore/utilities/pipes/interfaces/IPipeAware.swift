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
    
    :param: name name of the input pipe
    :param: pipe input Pipe Fitting
    */
    func acceptInputPipe(name: String, pipe: IPipeFitting)
    
    /**
    Connect output Pipe Fitting.
    
    :param: name name of the input pipe
    :param: pipe output Pipe Fitting
    */
    func acceptOutputPipe(name: String, pipe: IPipeFitting)
    
}
