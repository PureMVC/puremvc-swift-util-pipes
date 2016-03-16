//
//  Junction.swift
//  PureMVC SWIFT/MultiCore Utility – Pipes
//
//  Copyright(c) 2015-2025 Saad Shams <saad.shams@puremvc.org>
//  Your reuse is governed by the Creative Commons Attribution 3.0 License
//

import Foundation

/**
Pipe Junction.

Manages Pipes for a Module.

When you register a Pipe with a Junction, it is 
declared as being an INPUT pipe or an OUTPUT pipe.

You can retrieve or remove a registered Pipe by name, 
check to see if a Pipe with a given name exists, or if 
it exists AND is an INPUT or an OUTPUT Pipe.

You can send an `IPipeMessage` on a named INPUT Pipe 
or add a `PipeListener` to registered INPUT Pipe.
*/
public class Junction {
    
    /// INPUT Pipe Type
    public class var INPUT: String { return "input" }
    
    /// OUTPUT Pipe Type
    public class var OUTPUT: String { return "output" }
    
    /// The names of the INPUT pipes
    private var inputPipes = [String]()
    
    /// The names of the OUTPUT pipes
    private var outputPipes = [String]()
    
    /// The map of pipe names to their pipes
    private var pipesMap = [String: IPipeFitting]()
    
    // Concurrent queue for pipesMap
    // for speed and convenience of running concurrently while reading, and thread safety of blocking while mutating
    private let pipesMapQueue = dispatch_queue_create("org.puremvc.pipes.Junction.pipesMapQueue", DISPATCH_QUEUE_CONCURRENT)
    
    /// The map of pipe names to their types
    private var pipeTypesMap = [String: String]()
    
    /// Constructor.
    public init() {
        
    }
    
    /**
    Register a pipe with the junction.
    
    Pipes are registered by unique name and type, 
    which must be either `Junction.INPUT` 
    or `Junction.OUTPUT`.
 		
    NOTE: You cannot have an INPUT pipe and an OUTPUT
    pipe registered with the same name. All pipe names 
    must be unique regardless of type.
    
    - parameter name: name of the Pipe Fitting
    - parameter type: input or output
    - parameter pipe: instance of the `IPipeFitting`
    
    - returns: Bool true if successfully registered. false if another pipe exists by that name.
    */
    public func registerPipe(name: String, type: String, pipe: IPipeFitting) -> Bool {
        var success = true
        dispatch_barrier_sync(pipesMapQueue) {
            if self.pipesMap[name] == nil {
                
                self.pipesMap[name] = pipe
                self.pipeTypesMap[name] = type
                
                switch type {
                case Junction.INPUT:
                    self.inputPipes.append(name)
                case Junction.OUTPUT:
                    self.outputPipes.append(name)
                default:
                    success = false
                }
            } else {
                success = false
            }
        }
        return success
    }
    
    /**
    Does this junction have a pipe by this name?
    
    - parameter name: the pipe to check for
    - returns: Bool whether as pipe is registered with that name.
    */
    public func hasPipe(name: String) -> Bool {
        var result = false
        dispatch_sync(pipesMapQueue) {
            result = self.pipesMap[name] != nil
        }
        return result
    }
    
    /**
    Does this junction have an INPUT pipe by this name?
    
    - parameter name: the pipe to check for
    - returns: Bool whether an INPUT pipe is registered with that name.
    */
    public func hasInputPipe(name: String) -> Bool {
        var result = false
        dispatch_sync(pipesMapQueue) {
            result = self.hasPipe(name) && self.pipeTypesMap[name] == Junction.INPUT
        }
        return result
    }
    
    /**
    Does this junction have an OUTPUT pipe by this name?
    
    - parameter name: the pipe to check for
    - returns: Bool whether an OUTPUT pipe is registered with that name.
    */
    public func hasOutputPipe(name: String) -> Bool {
        var result = false
        dispatch_sync(pipesMapQueue) {
            result = self.hasPipe(name) && self.pipeTypesMap[name] == Junction.OUTPUT
        }
        return result
    }
    
    /**
    Remove the pipe with this name if it is registered.
    
    NOTE: You cannot have an INPUT pipe and an OUTPUT 
    pipe registered with the same name. All pipe names 
    must be unique regardless of type.
    
    - parameter name: the pipe to remove
    */
    public func removePipe(name: String) {
        if self.hasPipe(name) {
            dispatch_barrier_sync(pipesMapQueue) {
                if let type = self.pipeTypesMap[name] {
                    var pipesList:[String]
                    switch type {
                    case Junction.INPUT:
                        pipesList = self.inputPipes
                    case Junction.OUTPUT:
                        pipesList = self.outputPipes
                    default:
                        return
                    }
                    
                    for (index, _) in pipesList.enumerate() {
                        if pipesList[index] == name {
                            pipesList.removeAtIndex(index)
                            break
                        }
                    }
                    
                    self.pipesMap[name] = nil
                    self.pipeTypesMap[name] = nil
                }
            }
        }
    }
    
    /**
    Retrieve the named pipe.
    
    - parameter name: the pipe to retrieve
    - returns: IPipeFitting the pipe registered by the given name if it exists
    */
    public func retrievePipe(name: String) -> IPipeFitting? {
        var pipe: IPipeFitting?
        dispatch_sync(pipesMapQueue) {
            pipe = self.pipesMap[name]
        }
        return pipe
    }
    
    /**
    Add a PipeListener to an INPUT pipe.
    
    NOTE: there can only be one PipeListener per pipe, and the listener function must accept an IPipeMessage as its sole argument.
    
    - parameter inputPipeName: the INPUT pipe to add a PipeListener to
    - parameter context: the calling context or 'this' object
    - parameter listener: the function on the context to call
    */
    public func addPipeListener(inputPipeName: String, context: AnyObject, listener: IPipeMessage -> ()) -> Bool {
        var success = false
        dispatch_sync(pipesMapQueue) {
            if self.hasInputPipe(inputPipeName) {
                let pipe = self.pipesMap[inputPipeName]!
                success = pipe.connect(PipeListener(context: context, listener: listener))
            }
        }
        return success
    }
    
    /**
    Send a message on an OUTPUT pipe.
    
    - parameter outputPipeName: the OUTPUT pipe to send the message on
    - parameter message: the IPipeMessage to send
    */
    public func sendMessage(outputPipeName: String, message: IPipeMessage) -> Bool { //read
        var success = false
        dispatch_sync(pipesMapQueue) {
            if self.hasOutputPipe(outputPipeName) {
                let pipe = self.pipesMap[outputPipeName]!
                success = pipe.write(message)
            }
        }
        return success
    }
    
}

