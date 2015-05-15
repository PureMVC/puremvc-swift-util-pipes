//
//  JunctionMediator.swift
//  PureMVC SWIFT/MultiCore Utility – Pipes
//
//  Copyright(c) 2015-2025 Saad Shams <saad.shams@puremvc.org>
//  Your reuse is governed by the Creative Commons Attribution 3.0 License
//

import PureMVC

/**
Junction Mediator.

A base class for handling the Pipe Junction in an IPipeAware
Core.
*/
public class JunctionMediator: Mediator {
    
    /// Accept input pipe notification name constant.
    public class var ACCEPT_INPUT_PIPE: String { return "acceptInputPipe" }
    
    /// Accept output pipe notification name constant.
    public class var ACCEPT_OUTPUT_PIPE: String { return "acceptOutputPipe" }
     
    /// Constructor.
    public override init(mediatorName: String?, viewComponent: AnyObject?) {
        super.init(mediatorName: mediatorName, viewComponent: viewComponent)
    }
    
    /**
    List Notification Interests.
    
    Returns the notification interests for this base class. 
    Override in subclass and call `super.listNotificationInterests` 
    to get this list, then add any sublcass interests to 
    the array before returning.
    */
    public override func listNotificationInterests() -> [String] {
        return [
            JunctionMediator.ACCEPT_INPUT_PIPE,
            JunctionMediator.ACCEPT_OUTPUT_PIPE
        ]
    }
    
    /**
    Handle Notification.
    
    This provides the handling for common junction activities. It 
    accepts input and output pipes in response to `IPipeAware` 
    interface calls.
    
    Override in subclass, and call `super.handleNotification` 
    if none of the subclass-specific notification names are matched.
    */
    public override func handleNotification(notification: INotification) {
        
        switch notification.name {
        // accept an input pipe
        // register the pipe and if successful
        // set this mediator as its listener
        case JunctionMediator.ACCEPT_INPUT_PIPE:
            var inputPipeName = notification.type!
            var inputPipe = notification.body as! IPipeFitting
            
            if junction.registerPipe(inputPipeName, type: Junction.INPUT, pipe: inputPipe) { //weak reference to JunctionMediator (self) to avoid reference cycle with Junction, context is defined as weak too
                junction.addPipeListener(inputPipeName, context: self, listener: {[weak self] message in self?.handlePipeMessage(message); return})
            }
            
        // accept an output pipe
        case JunctionMediator.ACCEPT_OUTPUT_PIPE:
            var outputPipeName = notification.type!
            var outputPipe = notification.body as! IPipeFitting
            junction.registerPipe(outputPipeName, type: Junction.OUTPUT, pipe: outputPipe)
            
        default:
            return
        }
        
    }
    
    /**
    Handle incoming pipe messages.
    
    Override in subclass and handle messages appropriately for the module.
    */
    public func handlePipeMessage(message: IPipeMessage) {
        
    }
    
    /// The Junction for this Module.
    public var junction: Junction {
        return viewComponent as! Junction
    }
    
}
