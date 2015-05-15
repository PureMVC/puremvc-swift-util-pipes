//
//  IPipeMessage.swift
//  PureMVC SWIFT/MultiCore Utility – Pipes
//
//  Copyright(c) 2015-2025 Saad Shams <saad.shams@puremvc.org>
//  Your reuse is governed by the Creative Commons Attribution 3.0 License
//

/**
Pipe Message Interface.
    
`IPipeMessage`s are objects written intoto a Pipeline,
composed of `IPipeFitting`s. The message is passed from 
one fitting to the next in syncrhonous fashion.

Depending on type, messages may be handled differently by the 
fittings.
*/
public protocol IPipeMessage {
    
    /// Get or set type of this message
    var type: String { get set }
    
    /// Get or set priority of this message
    var priority: Int { get set }
    
    /// Get or set header of this message
    var header: Any? { get set }
    
    /// Get or set body of this message
    var body: Any? { get set }
    
}
