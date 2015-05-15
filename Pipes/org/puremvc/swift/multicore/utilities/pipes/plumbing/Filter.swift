//
//  Filter.swift
//  PureMVC SWIFT/MultiCore Utility – Pipes
//
//  Copyright(c) 2015-2025 Saad Shams <saad.shams@puremvc.org>
//  Your reuse is governed by the Creative Commons Attribution 3.0 License
//

/**
Pipe Filter.

Filters may modify the contents of messages before writing them to 
their output pipe fitting. They may also have their parameters and 
filter function passed to them by control message, as well as having 
their Bypass/Filter operation mode toggled via control message.
*/
public class Filter: Pipe {
    
    private var _name: String
    
    private var _params: Any?
    
    private var _filter: ((message: IPipeMessage, params: Any?) -> Bool)? = { (IPipeMessage, Any) -> Bool in return true }
    
    private var _mode = FilterControlMessage.FILTER
    
    /**
    Constructor.
    
    Optionally connect the output and set the parameters.
    */
    public init(name: String, output: IPipeFitting?=nil, filter: ((IPipeMessage, Any?) -> Bool)?=nil, params: Any?=nil) {
        _name = name
        super.init(output: output)
        
        if filter != nil { self.filter = filter }
        if params != nil { self.params = params }
    }
    
    /**
    Handle the incoming message.
    
    If message type is normal, filter the message (unless in BYPASS mode) 
    and write the result to the output pipe fitting if the filter 
    operation is successful.
    
    The FilterControlMessage.SET_PARAMS message type tells the Filter 
    that the message class is FilterControlMessage, which it 
    casts the message to in order to retrieve the filter parameters 
    object if the message is addressed to this filter.

    The FilterControlMessage.SET_FILTER message type tells the Filter 
    that the message class is FilterControlMessage,
    which it casts the message to in order to retrieve the filter function.
    
    The FilterControlMessage.BYPASS message type tells the Filter 
    that it should go into Bypass mode operation, passing all normal 
    messages through unfiltered.
    
    The FilterControlMessage.FILTER message type tells the Filter 
    that it should go into Filtering mode operation, filtering all 
    normal normal messages before writing out. This is the default 
    mode of operation and so this message type need only be sent to 
    cancel a previous BYPASS message.
   
    The Filter only acts on the control message if it is targeted 
    to this named filter instance. Otherwise it writes through to the 
    output.

    :returns: Boolean True if the filter process does not throw an error and subsequent operations 
    in the pipeline succede.
    */
    public override func write(message: IPipeMessage) -> Bool {
        var outputMessage: IPipeMessage
        var success = true
        
        // Filter normal messages
        switch message.type {
        case Message.NORMAL:
            if mode == FilterControlMessage.FILTER {
                success = applyFilter(message) ? output!.write(message) : false
            } else {
                success = output!.write(message)
            }
            
        // Accept parameters from control message
        case FilterControlMessage.SET_PARAMS:
            if isTarget(message) {
                params = (message as! FilterControlMessage).params
            } else {
                success = output!.write(message)
            }
            
        // Accept filter function from control message
        case FilterControlMessage.SET_FILTER:
            if isTarget(message) {
                self.filter = (message as! FilterControlMessage).filter
            } else {
                success = output!.write(message)
            }
            
        // Toggle between Filter or Bypass operational modes
        case FilterControlMessage.BYPASS,
        FilterControlMessage.FILTER:
            if isTarget(message) {
                mode = message.type
            } else {
                success = output!.write(message)
            }
            
        // Write control messages for other fittings through
        default:
            success = output!.write(message)
        }
        
        return success
    }
    
    /// Is the message directed at this filter instance?
    func isTarget(message: IPipeMessage) -> Bool {
        return (message as! FilterControlMessage).name == self.name
    }

    /// Filter the message.
    func applyFilter(message: IPipeMessage) -> Bool {
        return self.filter!(message: message, params: self.params)
    }
    
    /// Get or set the mode */
    public var mode: String {
        get { return _mode }
        set { _mode = newValue }
    }
    
    /**
    Get and Set the Filter function.
    
    It must accept two arguments; an IPipeMessage,
    and a parameter Object, which can contain whatever
    arbitrary properties and values your filter method 
    requires.
    
    :param: newValue the filter function.
    */
    public var filter: ((message: IPipeMessage, params: Any?) -> Bool)?  {
        get { return _filter }
        set { _filter = newValue }
    }
    
    /**
    Get and Set the Filter parameters.
    
    This can be an object can contain whatever arbitrary 
    properties and values your filter method requires to 
    operate.

    :param: newValue the parameters object
    */
    public var params: Any? {
        get { return _params }
        set { _params = newValue }
    }
    
    /// Get the name
    public var name: String {
        return _name
    }
    
}
