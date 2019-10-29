//
//  TeeMergeTest.swift
//  PureMVC SWIFT/MultiCore Utility – Pipes
//
//  Copyright(c) 2015-2019 Saad Shams <saad.shams@puremvc.org>
//  Your reuse is governed by the Creative Commons Attribution 3.0 License
//

import XCTest
@testable import Pipes

/**
Test the TeeMerge class.
*/
class TeeMergeTest: XCTestCase, XMLParserDelegate {

    private var testAtt: String?
    
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
    Test connecting an output and several input pipes to a merging tee.
    */
    func testConnectingIOPipes() {
        // create input pipe
        let output1: IPipeFitting = Pipe()
        
        // create input pipes 1, 2, 3 and 4
        let pipe1: IPipeFitting = Pipe()
        let pipe2: IPipeFitting = Pipe()
        let pipe3: IPipeFitting = Pipe()
        let pipe4: IPipeFitting = Pipe()
        
        // create splitting tee (args are first two input fittings of tee)
        let teeMerge: TeeMerge = TeeMerge(input1: pipe1, input2: pipe2)
        
        // connect 2 extra inputs for a total of 4
        let connectedExtra1 = teeMerge.connectInput(pipe3)
        let connectedExtra2 = teeMerge.connectInput(pipe4)
        
        // connect the single output
        _ = output1.connect(teeMerge)
        
        // test assertions
        XCTAssertNotNil(pipe1, "Expecting pipe1 is Pipe")
        XCTAssertNotNil(pipe2, "Expecting pipe2 is Pipe")
        XCTAssertNotNil(pipe3, "Expecting pipe3 is Pipe")
        XCTAssertNotNil(pipe4, "Expecting pipe4 is Pipe")
        XCTAssertNotNil(teeMerge, "Expecting teeMerge not nil")
        XCTAssertTrue(connectedExtra1, "Expecting connected extra input 1")
        XCTAssertTrue(connectedExtra2, "Expecting connected extra input 2")
    }
    
    /**
    Test receiving messages from two pipes using a TeeMerge.
    */
    func testReceiveMessagesFromTwoPipesViaTeeMerge() {
        let data1: NSData = "<testMessage testAtt='Pipe 1 Message'/>".data(using: String.Encoding.utf8, allowLossyConversion: false)! as NSData
        let data2: NSData = "<testMessage testAtt='Pipe 2 Message'/>".data(using: String.Encoding.utf8, allowLossyConversion: false)! as NSData
        
        // create a message to send on pipe 1
        let pipe1Message: IPipeMessage = Message(type: Message.NORMAL, header: ["testProp": 1], body: data1, priority: Message.PRIORITY_LOW)
        
        // create a message to send on pipe 2
        let pipe2Message: IPipeMessage = Message(type: Message.NORMAL, header: ["testProp": 2], body: data2, priority: Message.PRIORITY_HIGH)
        
        // create pipes 1 and 2
        let pipe1: IPipeFitting = Pipe()
        let pipe2: IPipeFitting = Pipe()
        
        // create merging tee (args are first two input fittings of tee)
        let teeMerge = TeeMerge(input1: pipe1, input2: pipe2)
        
        // create listener
        let listener: PipeListener = PipeListener(context: self, listener: self.callBackMethod)
        
        // connect the listener to the tee and write the messages
        let connected = teeMerge.connect(listener)
        
        // write messages to their respective pipes
        let pipe1Written = pipe1.write(pipe1Message)
        let pipe2Written = pipe2.write(pipe2Message)
        
        // test assertions
        XCTAssertNotNil(pipe1Message as! Message, "Expecting pipe1Message as Message")
        XCTAssertNotNil(pipe2Message as! Message, "Expecting pipe2Message as Message")
        XCTAssertNotNil(pipe1, "Expecting pipe1 as Pipe")
        XCTAssertNotNil(pipe2, "Expecting pipe2 as Pipe")
        XCTAssertNotNil(teeMerge as TeeMerge, "Expecting teeMerge as TeeMerge")
        XCTAssertNotNil(listener as PipeListener, "Expecting listener as PipeListener")
        XCTAssertTrue(connected, "Expecting connected listener to merging tee")
        XCTAssertTrue(pipe1Written, "Expecting wrote message to pipe1")
        XCTAssertTrue(pipe2Written, "Expecting wrote message to pipe2")
        
        // test that both messages were received, then test
        // FIFO order by inspecting the messages themselves
        XCTAssertTrue(messagesReceived.count == 2, "Expecting received 2 messages")
        
        // test message 1 assertions
        let message1: IPipeMessage = messagesReceived.remove(at: 0)
        XCTAssertNotNil(message1 as! Message, "Expecting message1 as Message")
        XCTAssertTrue(message1 as! Message === pipe1Message as! Message, "Expecting message1 === pipe1Message")
        XCTAssertTrue(message1.type == Message.NORMAL, "Expecting message1.type == Message.NORMAL")
        XCTAssertTrue((message1.header as! Dictionary)["testProp"] == 1, "message1.header['testProp'] == 1")
        
        var parser = XMLParser(data: (message1.body as! Data) as Data)
        parser.delegate = self
        parser.parse()
        
        XCTAssertTrue(self.testAtt == "Pipe 1 Message", "self.testAtt == Pipe 1 Message")
        self.testAtt = nil
        
        XCTAssertTrue(message1.priority == Message.PRIORITY_LOW, "Expecting message1.priority == Message.PRIORITY_LOW")
        
        // test message 2 assertions
        let message2: IPipeMessage = messagesReceived.remove(at: 0)
        XCTAssertNotNil(message2 is Message, "Expecting message2 as Message")
        XCTAssertTrue(message2 as! Message === pipe2Message as! Message, "Expecing message2 === pipe2Message")
        XCTAssertTrue(message2.type == Message.NORMAL, "Expecting message2.type == Message.NORMAL")
        
        parser = XMLParser(data: message2.body as! Data)
        parser.delegate = self
        parser.parse()
        
        XCTAssertTrue(self.testAtt == "Pipe 2 Message", "Expecting message2.body equal to 'Pipe 2 Message'")
        self.testAtt = nil
        
        XCTAssertTrue(message2.priority == Message.PRIORITY_HIGH, "Expecting message.priority == Message.PRIORITY_HIGHT")
    }
    
    /**
    Test receiving messages from four pipes using a TeeMerge.
    */
    func testReceiveMessagesFromFourPipesViaTeeMerge() {
        // create a message to send on pipe 1
        let pipe1Message = Message(type: Message.NORMAL, header: ["testProp": 1])
        let pipe2Message = Message(type: Message.NORMAL, header: ["testProp": 2])
        let pipe3Message = Message(type: Message.NORMAL, header: ["testProp": 3])
        let pipe4Message = Message(type: Message.NORMAL, header: ["testProp": 4])
        
        // create pipes 1, 2, 3 and 4
        let pipe1: IPipeFitting = Pipe()
        let pipe2: IPipeFitting = Pipe()
        let pipe3: IPipeFitting = Pipe()
        let pipe4: IPipeFitting = Pipe()
        
        // create merging tee
        let teeMerge: TeeMerge = TeeMerge(input1: pipe1, input2: pipe2)
        let connectedExtraInput3 = teeMerge.connectInput(pipe3)
        let connectedExtraInput4 = teeMerge.connectInput(pipe4)
        
        // create listener
        let listener = PipeListener(context: self, listener: self.callBackMethod)
        
        // connect the listener to the tee and write the messages
        let connected = teeMerge.connect(listener)
        
        // write messages to their respective pipes
        let pipe1written = pipe1.write(pipe1Message)
        let pipe2written = pipe2.write(pipe2Message)
        let pipe3written = pipe3.write(pipe3Message)
        let pipe4written = pipe4.write(pipe4Message)
        
        // test assertions
        XCTAssertNotNil(pipe1Message as Message, "pipe1Message as Message")
        XCTAssertNotNil(pipe2Message as Message, "pipe2Message as Message")
        XCTAssertNotNil(pipe3Message as Message, "pipe3Message as Message")
        XCTAssertNotNil(pipe4Message as Message, "pipe4Message as Message")
        XCTAssertNotNil(pipe1, "Expecting pipe1 not nil")
        XCTAssertNotNil(pipe2, "Expecting pipe2 not nil")
        XCTAssertNotNil(pipe3, "Expecting pipe3 not nil")
        XCTAssertNotNil(pipe4, "Expecting pipe4 not nil")
        XCTAssertNotNil(teeMerge as TeeMerge, "Expecting teeMerge as TeeMerge")
        XCTAssertNotNil(listener as PipeListener, "Expecting listener as PipeListener")
        XCTAssertTrue(connected, "Expecting connected listener to merging tee")
        XCTAssertTrue(connectedExtraInput3, "Expecting connected extra input pipe3 to merging tee")
        XCTAssertTrue(connectedExtraInput4, "Expecting connected extra input pipe4 to merging tee")
        XCTAssertTrue(pipe1written, "Expecting wrote message to pipe 1")
        XCTAssertTrue(pipe2written, "Expecting wrote message to pipe 2")
        XCTAssertTrue(pipe3written, "Expecting wrote message to pipe 3")
        XCTAssertTrue(pipe4written, "Expecting wrote message to pipe 4")
        
        // test that both messages were received, then test
        // FIFO order by inspecting the messages themselves
        XCTAssertTrue(messagesReceived.count == 4, "Expecting received 4 messages")
        
        // test message 1 assertions
        let message1: IPipeMessage = messagesReceived.remove(at: 0)
        XCTAssertNotNil(message1 as! Message, "Expecting message 1 as Message")
        XCTAssertTrue(message1 as! Message === pipe1Message as Message, "Expecting message1 === pipe1Message")
        XCTAssertEqual(message1.type, Message.NORMAL, "Expecting message1.type == Message.NORMAL")
        XCTAssertTrue((message1.header as! Dictionary)["testProp"] == 1, "Expecting message1.header['testProp'] == 1")
        
        // test message 2 assertions
        let message2: IPipeMessage = messagesReceived.remove(at: 0)
        XCTAssertNotNil(message2 as! Message, "Expecting message 2 as Message")
        XCTAssertTrue(message2 as! Message === pipe2Message as Message, "Expecting message2 === pipe1Message")
        XCTAssertEqual(message2.type, Message.NORMAL, "Expecting message2.type == Message.NORMAL")
        XCTAssertTrue((message2.header as! Dictionary)["testProp"] == 2, "Expecting message2.header['testProp'] == 2")
        
        // test message 3 assertions
        let message3: IPipeMessage = messagesReceived.remove(at: 0)
        XCTAssertNotNil(message3 as! Message, "Expecting message 3 as Message")
        XCTAssertTrue(message3 as! Message === pipe3Message as Message, "Expecting message3 === pipe1Message")
        XCTAssertEqual(message3.type, Message.NORMAL, "Expecting message3.type == Message.NORMAL")
        XCTAssertTrue((message3.header as! Dictionary)["testProp"] == 3, "Expecting message1.header['testProp'] == 3")
        
        // test message 4 assertions
        let message4: IPipeMessage = messagesReceived.remove(at: 0)
        XCTAssertNotNil(message4 as! Message, "Expecting message 4 as Message")
        XCTAssertTrue(message4 as! Message === pipe4Message as Message, "Expecting message4 === pipe1Message")
        XCTAssertEqual(message4.type, Message.NORMAL, "Expecting message1.type == Message.NORMAL")
        XCTAssertTrue((message4.header as! Dictionary)["testProp"] == 4, "Expecting message4.header['testProp'] == 4")
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
    
     //XML parsing routing
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        self.testAtt = attributeDict["testAtt"]
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }

}
