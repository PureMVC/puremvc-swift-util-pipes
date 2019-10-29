//
//  TeeSplitTest.swift
//  PureMVC SWIFT/MultiCore Utility – Pipes
//
//  Copyright(c) 2015-2019 Saad Shams <saad.shams@puremvc.org>
//  Your reuse is governed by the Creative Commons Attribution 3.0 License
//

import XCTest
@testable import Pipes

/**
Test the TeeSplit class.
*/
class TeeSplitTest: XCTestCase {

    /**
    Array of received messages.
    
    Used by `callBackMedhod` as a place to store
    the recieved messages.
    */
    private var messagesReceived: [IPipeMessage] = []
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    /**
    Test connecting and disconnecting I/O Pipes.
    
    Connect an input and several output pipes to a splitting tee.
    Then disconnect all outputs in LIFO order by calling disconnect
    repeatedly.
    */
    func testConnectingAndDisconnectingIOPipes() {
        // create input pipe
        let input1: IPipeFitting = Pipe()
        
        // create output pipes 1, 2, 3 and 4
        let pipe1: IPipeFitting = Pipe()
        let pipe2: IPipeFitting = Pipe()
        let pipe3: IPipeFitting = Pipe()
        let pipe4: IPipeFitting = Pipe()
        
        // create splitting tee (args are first two output fittings of tee)
        let teeSplit: TeeSplit = TeeSplit(output1: pipe1, output2: pipe2)
        
        // connect 2 extra outputs for a total of 4
        let connectedExtra1 = teeSplit.connect(pipe3)
        let connectedExtra2 = teeSplit.connect(pipe4)
        
        // connect the single input
        _ = input1.connect(teeSplit)
        
        // test assertions
        XCTAssertNotNil(pipe1, "Expecting pipe1 as Pipe")
        XCTAssertNotNil(pipe2, "Expecting pipe2 as Pipe")
        XCTAssertNotNil(pipe3, "Expecting pipe3 as Pipe")
        XCTAssertNotNil(pipe4, "Expecting pipe4 as Pipe")
        XCTAssertNotNil(teeSplit as TeeSplit, "Expecting teeSolit is TeeSplit")
        XCTAssertTrue(connectedExtra1, "Expecting connected pipe 3")
        XCTAssertTrue(connectedExtra2, "Expecting connected pipe 4")
        
          //test LIFO order of output disconnection
        XCTAssertNotNil(teeSplit.disconnect(), "Expecting disconnected pipe 4")
        XCTAssertNotNil(teeSplit.disconnect(), "Expecting disconnected pipe 3")
        XCTAssertNotNil(teeSplit.disconnect(), "Expecting disconnected pipe 2")
        XCTAssertNotNil(teeSplit.disconnect(), "Expecting disconnected pipe 1")
        XCTAssertNil(teeSplit.disconnect(), "Expecting nil")
    }
    
    /**
    Test disconnectFitting method.
    
    Connect several output pipes to a splitting tee.
    Then disconnect specific outputs, making sure that once
    a fitting is disconnected using disconnectFitting, that
    it isn't returned when disconnectFitting is called again.
    Finally, make sure that the when a message is sent to
    the tee that the correct number of output messages is
    written.
    */
    func testDisconnectFitting() {
        messagesReceived = []
        
        // create output pipes 1, 2, 3 and 4
        let pipe1: IPipeFitting = Pipe()
        let pipe2: IPipeFitting = Pipe()
        let pipe3: IPipeFitting = Pipe()
        let pipe4: IPipeFitting = Pipe()
        
        // setup pipelisteners
        XCTAssertTrue(pipe1.connect(PipeListener(context: self, listener: self.callBackMethod)), "Expecting pipe1 connection to PipeListener")
        XCTAssertTrue(pipe2.connect(PipeListener(context: self, listener: self.callBackMethod)), "Expecting pipe1 connection to PipeListener")
        XCTAssertTrue(pipe3.connect(PipeListener(context: self, listener: self.callBackMethod)), "Expecting pipe1 connection to PipeListener")
        XCTAssertTrue(pipe4.connect(PipeListener(context: self, listener: self.callBackMethod)), "Expecting pipe1 connection to PipeListener")
        
        // create splitting tee
        let teeSplit = TeeSplit()
        
        // add outputs
        XCTAssertTrue(teeSplit.connect(pipe1), "Expecting pipe1 connection")
        XCTAssertTrue(teeSplit.connect(pipe2), "Expecting pipe2 connection")
        XCTAssertTrue(teeSplit.connect(pipe3), "Expecting pipe3 connection")
        XCTAssertTrue(teeSplit.connect(pipe4), "Expecting pipe4 connection")
        
        // test assertions
        XCTAssertTrue((teeSplit.disconnectFitting(pipe4) != nil), "Expecting teeSplit.disconnectFitting(pipe4) === pipe4")
        XCTAssertNil(teeSplit.disconnectFitting(pipe4), "Expecting teeSplit.disconnectFitting(pipe4) == nil")
        
        // Write a message to the tee
        XCTAssertTrue(teeSplit.write(Message(type: Message.NORMAL)), "Expecting message written to teeSplit")        
        
        // test assertions
        XCTAssertTrue(messagesReceived.count == 3, "Expecting messagesReceived.count == 3")
    }
    
    /**
    Test receiving messages from two pipes using a TeeMerge.
    */
    func testReceiveMessagesFromTwoTeeSplitOutputs() {
        messagesReceived = []
        
        // create a message to send on pipe 1
        let message: IPipeMessage = Message(type: Message.NORMAL, body: ["testProp": 1])
        
        // create output pipes 1 and 2
        let pipe1: IPipeFitting = Pipe()
        let pipe2: IPipeFitting = Pipe()
        
        // create and connect anonymous listeners
        let connected1 = pipe1.connect(PipeListener(context: self, listener: self.callBackMethod))
        let connected2 = pipe2.connect((PipeListener(context: self, listener: self.callBackMethod)))
        
        // create splitting tee (args are first two output fittings of tee)
        let teeSplit = TeeSplit(output1: pipe1, output2: pipe2)
        
        // write messages to their respective pipes
        let written = teeSplit.write(message)
        
        // test assertions
        XCTAssertNotNil(message is Message, "message is not nil")
        XCTAssertNotNil(teeSplit as TeeSplit, "teeSplit is not nil")
        XCTAssertTrue(connected1, "Expecting connected anonymous listener to pipe 1")
        XCTAssertTrue(connected2, "Expecting connected anonymous listener to pipe 2")
        XCTAssertTrue(written, "Expecting wrote single message to tee")
        
        // test that both messages were received, then test
        // FIFO order by inspecting the messages themselves
        XCTAssertTrue(messagesReceived.count == 2, "Expecting received 2 messages")
        
        // test message 1 assertions
        let message1: IPipeMessage = messagesReceived.remove(at: 0)
        XCTAssertNotNil(message1 as! Message, "message1 not nil")
        XCTAssertTrue(message1 as! Message === message as! Message, "Expecting message1 === message")
        
        // test message 2 assertions
        let message2: IPipeMessage = messagesReceived.remove(at: 0)
        XCTAssertNotNil(message2 as? Message, "Expecting message2 is not nil")
        XCTAssertTrue(message2 as! Message === message as! Message, "Expecting message2 === message")
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
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }

}
