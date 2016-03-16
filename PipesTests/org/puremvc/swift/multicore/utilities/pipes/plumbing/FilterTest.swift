//
//  FilterTest.swift
//  PureMVC SWIFT/MultiCore Utility – Pipes
//
//  Copyright(c) 2015-2025 Saad Shams <saad.shams@puremvc.org>
//  Your reuse is governed by the Creative Commons Attribution 3.0 License
//

import Pipes
import XCTest

/**
Test the Filter class.
*/
class FilterTest: XCTestCase {

    /**
    Array of received messages.
    
    Used by `callBackMedhod` as a place to store
    the recieved messages.
    */
    private var messagesReceived = [IPipeMessage]()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    /**
    Test connecting input and output pipes to a filter as well as disconnecting the output.
    */
    func testConnectingAndDisconnectingIOPipes() {
        // create output pipes 1
        let pipe1: IPipeFitting = Pipe()
        let pipe2: IPipeFitting = Pipe()
        
        //create filter
        let filter: Filter = Filter(name: "TestFilter")
        
        // connect input fitting
        let connectInput = pipe1.connect(filter)
        
        XCTAssertTrue(connectInput, "Expecting pipe to be connected")
        
        // connect output fitting
        let connectedOutput = filter.connect(pipe2)
        
        // test assertions
        XCTAssertNotNil(pipe1 as! Pipe, "Expecting pipe1 is not nil")
        XCTAssertNotNil(pipe2 as! Pipe, "Expecting pipe2 is not nil")
        XCTAssertNotNil(filter as Filter, "Expecting filter is not nil")
        XCTAssertTrue(connectedOutput, "Expecting connected input")
        XCTAssertTrue(connectedOutput, "Expecting connected output")
        
        // disconnect pipe 2 from filter
        let disconnectedPipe = filter.disconnect()
        XCTAssertTrue(disconnectedPipe as! Pipe === pipe2 as! Pipe, "Expecting disconnected pipe2 from filter")
    }
    
    /**
    Test applying filter to a normal message.
    */
    func testFilteringNormalMessage() {
        // create messages to send to the queue
        let message: IPipeMessage = Message(type: Message.NORMAL, header: ["width": 10, "height": 2])
        
        // create filter, attach an anonymous listener to the filter output to receive the message,
        // pass in an anonymous function an parameter object
        let filter = Filter(name: "scale", output: PipeListener(context: self, listener: self.callBackMethod),
            filter: { (var message: IPipeMessage, params: Any?) -> Bool in
                let factor = (params as! [String: Int])["factor"]
            
                var header = message.header as! [String: Int]
                header.updateValue(header["width"]! * factor!, forKey: "width")
                header.updateValue(header["height"]! * factor!, forKey: "height")
            
                message.header = header
            
                return true
            },
            params: ["factor": 10])
        
        // write messages to the filter
        let written = filter.write(message)
        
        // test assertions
        XCTAssertNotNil(message as! Message, "Expecting message is Message")
        XCTAssertNotNil(filter as Filter, "Expecting filter is Filter")
        XCTAssertTrue(written, "expecting wrote message to filter")
        XCTAssertTrue(messagesReceived.count == 1, "Expecting received 1 messages")
        
        // test filtered message assertions
        let received = messagesReceived.removeAtIndex(0)
        XCTAssertNotNil(received as! Message, "received is not nil")
        XCTAssertTrue(received as! Message === message as! Message, "received === message")
        XCTAssertTrue((received.header as! [String: Int])["width"] == 100, "Expecting received.header['width'] == 100")
        XCTAssertTrue((received.header as! [String: Int])["height"] == 20, "Expecting received.header['height'] == 20")
    }
    
    /**
    Test setting filter to bypass mode, writing, then setting back to filter mode and writing.
    */
    func testBypassAndFilterModeToggle() {
        // create messages to send to the queue
        let message: IPipeMessage = Message(type: Message.NORMAL, header: ["width": 10, "height": 2])
        
        // create filter, attach an anonymous listener to the filter output to receive the message,
        // pass in an anonymous function an parameter object
        let filter = Filter(name: "scale", output: PipeListener(context: self, listener: self.callBackMethod),
            filter: { (var message: IPipeMessage, params: Any?) -> Bool in
                let factor = (params as! [String: Int])["factor"]
                var header = message.header as! [String: Int]
                header.updateValue(header["width"]! * factor!, forKey: "width")
                header.updateValue(header["height"]! * factor!, forKey: "height")
                message.header = header
                return true
            },
            params: ["factor": 10])
        
        // create bypass control message
        let bypassMessage: FilterControlMessage = FilterControlMessage(type: FilterControlMessage.BYPASS, name: "scale")
        
        // write bypass control message to the filter
        let bypassWritten = filter.write(bypassMessage)
        
        // write normal message to the filter
        let written1 = filter.write(message)
        
        // test assertions
        XCTAssertNotNil(message as! Message, "Expecting message is Message")
        XCTAssertNotNil(filter as Filter, "Expecting filter is Filter")
        XCTAssertTrue(bypassWritten, "Expecting wrote bypass message to filter")
        XCTAssertTrue(written1, "Expecting wrote normal message to filter")
        XCTAssertTrue(messagesReceived.count == 1, "Expecting received 1 messages")
        
        // test filtered message assertions (no change to message)
        var received1 = messagesReceived.removeAtIndex(0) as IPipeMessage
        XCTAssertNotNil(received1 as! Message, "Expecting received1 is Message")
        XCTAssertTrue(received1 as! Message === message as! Message, "Expecting received1 === message")
        XCTAssertTrue((received1.header as! [String: Int])["width"] == 10, "Expecting recevied1.header['width'] == 10")
        XCTAssertTrue((received1.header as! [String: Int])["height"] == 2, "Expecting received1.header['height'] == 2")
        
        // create filter control message
        let filterMessage = FilterControlMessage(type: FilterControlMessage.FILTER, name: "scale")
        
        // write bypass control message to the filter
        let filterWritten = filter.write(filterMessage)
        
        //let write normal message to the filter again
        let written2 = filter.write(message)
        
        // test assertions
        XCTAssertTrue(filterWritten, "Expecting wrote filter message to filter")
        XCTAssertTrue(written2, "Expecting wrote normal message to filter")
        XCTAssertTrue(messagesReceived.count == 1, "Expecting received 1 messages")
        
        // test filtered message assertions (message filtered)
        var received2 = messagesReceived.removeAtIndex(0) as IPipeMessage
        XCTAssertNotNil(received2 as! Message, "Expecting received2 is IPipeMessage")
        XCTAssertNotNil(received2 as! Message === message as! Message, "Expecting received2 === message")
        XCTAssertTrue((received2.header as! [String: Int])["width"] == 100, "Expecting received2.header['width'] == 100")
        XCTAssertTrue((received2.header as! [String: Int])["height"] == 20, "Expecting received2.header['height'] == 20")
    }
    
    /**
    Test setting filter parameters by sending control message.
    */
    func testSetParamsByControlMessage() {
        // create messages to send to the queue
        let message = Message(type: Message.NORMAL, header: ["width": 10, "height": 2])
        
        // create filter, attach an anonymous listener to the filter output to receive the message,
        // pass in an anonymous function an parameter object
        let filter = Filter(name: "scale", output: PipeListener(context: self, listener: self.callBackMethod),
            filter: { (var message: IPipeMessage, params: Any?) in
                var header = message.header as! [String: Int]
                let factor = (params as! [String: Int])["factor"]
                header["width"]  = header["width"]! * factor!
                header["height"] = header["height"]! * factor!
                message.header = header
                return true
            },
            params: ["factor": 10])
        
        // create setParams control message
        let setParamsMessage = FilterControlMessage(type: FilterControlMessage.SET_PARAMS, name: "scale", filter: nil, params: ["factor": 5])
        
        // write filter control message to the filter
        let setParamsWritten = filter.write(setParamsMessage)
        
        // write normal message to the filter
        let written = filter.write(message)
        
        // test assertions
        XCTAssertNotNil(message as Message, "Expecting message is Message")
        XCTAssertNotNil(filter as Filter, "Expecting filter is Filter")
        XCTAssertTrue(setParamsWritten, "Expecting wrote set_params message to filter")
        XCTAssertTrue(written, "Expecting wrote normal message to filter")
        XCTAssertTrue(messagesReceived.count == 1, "Expecting received 1 messages")
        
        // test filtered message assertions (message filtered with overridden parameters)
        var received = messagesReceived.removeAtIndex(0) as IPipeMessage
        XCTAssertNotNil(received as! Message, "Expecting received as Message")
        XCTAssertTrue(received as! Message === message as Message, "Expecting received === message")
        XCTAssertTrue((received.header as! [String: Int])["width"] == 50, "Expecting received.header['width'] == 50")
        XCTAssertTrue((received.header as! [String: Int])["height"] == 10, "Expecting received.header['height'] == 10")
    }
    
    /**
    Test setting filter function by sending control message.
    */
    func testSetFilterByControlMessage() {
        // create messages to send to the queue
        let message = Message(type: Message.NORMAL, header: ["width": 10, "height": 2])
        
        // create filter, attach an anonymous listener to the filter output to receive the message,
        // pass in an anonymous function and an anonymous parameter object
        let filter = Filter(name: "scale", output: PipeListener(context: self, listener: self.callBackMethod),
            filter: { (var message: IPipeMessage, params: Any?) -> Bool in
                var header = message.header as! [String: Int]
                let factor = (params as! [String: Int])["factor"]
                header.updateValue(header["width"]! * factor!, forKey: "width")
                header.updateValue(header["height"]! * factor!, forKey: "height")
                message.header = header
                return true
        }, params: ["factor": 10])
        
        // create setFilter control message
        let setFilterMessage = FilterControlMessage(type: FilterControlMessage.SET_FILTER, name: "scale",
            filter: { (var message: IPipeMessage, params: Any?) -> Bool in
                var header = message.header as! [String: Int]
                let factor = (params as! [String: Int])["factor"]
                header.updateValue(header["width"]! / factor!, forKey: "width")
                header.updateValue(header["height"]! / factor!, forKey: "height")
                message.header = header
                return true
            },
            params: nil)
        
        // write filter control message to the filter
        let setFilterWritten = filter.write(setFilterMessage)
        
        // write normal message to the filter
        let written = filter.write(message)
        
        // test assertions
        XCTAssertNotNil(message as Message, "Expecing message is Message")
        XCTAssertNotNil(filter as Filter, "Expecting filter is Filter")
        XCTAssertTrue(setFilterWritten, "Expecting wrote message to filter")
        XCTAssertTrue(written, "Expecting wrote normal message to filter")
        XCTAssertTrue(messagesReceived.count == 1, "Expecting received 1 messages")
        
        // test filtered message assertions (message filtered with overridden filter function)
        var received = messagesReceived.removeAtIndex(0) as IPipeMessage
        XCTAssertNotNil(received as! Message, "Expecting received as Message")
        XCTAssertTrue(received as! Message === message as Message, "Expecting received === message") // object equality
        XCTAssertTrue((received.header as! [String: Int])["width"] == 1, "Expecting received.header['width'] == 1")
        XCTAssertTrue((received.header as! [String: Int])["height"] == 0, "Expecting received.header['height'] == 0")
    }
    
    /**
    Test using a filter function to stop propagation of a message.
    
    The way to stop propagation of a message from within a filter
    is to throw an error from the filter function. This test creates
    two NORMAL messages, each with header objects that contain
    a `bozoLevel` property. One has this property set to
    10, the other to 3.
    
    Creates a Filter, named 'bozoFilter' with an anonymous pipe listener
    feeding the output back into this test. The filter funciton is an
    anonymous function that throws an error if the message's bozoLevel
    property is greater than the filter parameter `bozoThreshold`.
    the anonymous filter parameters object has a `bozoThreshold`
    value of 5.
    
    The messages are written to the filter and it is shown that the
    message with the `bozoLevel` of 10 is not written, while
    the message with the `bozoLevel` of 3 is.
    */
    func testUseFilterToStopAMessage() {
        // create messages to send to the queue
        let message1 = Message(type: Message.NORMAL, header: ["bozoLevel": 10, "user": 1])
        let message2 = Message(type: Message.NORMAL, header: ["bozoLevel": 3, "user": 2])
        
        // create filter, attach an anonymous listener to the filter output to receive the message,
        // pass in an anonymous function and an anonymous parameter object
        let filter = Filter(name: "bozoFilter", output: PipeListener(context: self, listener: self.callBackMethod),
            filter: { (message: IPipeMessage, params: Any?) -> Bool in
                var header = message.header as! [String: Int]
                let bozoThreshold = (params as! [String: Int])["bozoThreshold"]
                return header["bozoLevel"]! > bozoThreshold ? false : true
            },
            params: ["bozoThreshold": 5])
        
        // write normal message to the filter
        let written1 = filter.write(message1)
        let written2 = filter.write(message2)
        
        // test assertions
        XCTAssertNotNil(message1 as Message, "Expecting message is Message")
        XCTAssertNotNil(message2 as Message, "Expecting message is Message")
        XCTAssertNotNil(filter as Filter, "Expecting filter as Filter")
        XCTAssertTrue(written1 == false, "Expecting failed to write bad message")
        XCTAssertTrue(written2 == true, "Expecting wrote good message")
        XCTAssertTrue(messagesReceived.count == 1, "Expecting received 1 messages")
        
        // test filtered message assertions (message with good auth token passed
        let received = messagesReceived.removeAtIndex(0) as IPipeMessage
        XCTAssertNotNil(received as! Message, "Expecting received is Message") // object equality
        XCTAssertTrue(received as! Message === message2 as Message, "Expecting received === message2")
    }
    
    /**
    Callback given to `PipeListener` for incoming message.
    
    Used by `testReceiveMessageViaPipeListener`
    to get the output of pipe back into this  test to see
    that a message passes through the pipe.
    */
    private func callBackMethod(message: IPipeMessage) {
        messagesReceived.append(message)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
