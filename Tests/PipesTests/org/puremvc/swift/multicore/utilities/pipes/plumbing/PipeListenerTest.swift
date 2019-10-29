//
//  PipeListenerTest.swift
//  PureMVC SWIFT/MultiCore Utility – Pipes
//
//  Copyright(c) 2015-2019 Saad Shams <saad.shams@puremvc.org>
//  Your reuse is governed by the Creative Commons Attribution 3.0 License
//

import XCTest
@testable import Pipes

/**
Test the PipeListener class.
*/
class PipeListenerTest: XCTestCase, XMLParserDelegate {

    private var messageReceived: IPipeMessage?
    private var elementName: String?
    private var testAtt: String?
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    /**
    Test connecting a pipe listener to a pipe.
    */
    func testConnectingToAPipe() {
        // create pipe and listener
        let pipe = Pipes.Pipe()
        let listener = PipeListener(context: self, listener: callBackMethod)
        
        // connect the listener to the pipe
        let success = pipe.connect(listener)
        
        //test assertions
        XCTAssertNotNil(pipe, "Expecting pipe not nil")
        XCTAssertTrue(success, "Expecting successfully connected listener to pipe")
    }
    
    /**
    Test receiving a message from a pipe using a PipeListener.
    */
    func testReceiveMessageViaPipeListener() {
        let data: NSData = "<testMessage testAtt='Hello'/>".data(using: String.Encoding.utf8, allowLossyConversion: false)! as NSData
        
        // create a message
        let messageToSend: IPipeMessage = Message(type: Message.NORMAL, header: ["testProp" : "testval"], body: data, priority: Message.PRIORITY_HIGH)
        
        // create pipe and listener
        let pipe: IPipeFitting = Pipe()
        let listener: PipeListener = PipeListener(context: self, listener: self.callBackMethod)
        
        // connect the listener to the pipe and write the message
        let connected: Bool = pipe.connect(listener)
        let written: Bool = pipe.write(messageToSend)
        
        // test assertions
        XCTAssertTrue(connected, "Expected connected listener to pipe")
        XCTAssertTrue(written, "Expecting wrote message to pipe")
        XCTAssertNotNil(messageReceived as! Message, "Expecting messageReceived is Message")
        XCTAssertTrue(messageReceived!.type == Message.NORMAL, "Expecting messageReceived.type == Message.NORMAL")
        XCTAssertTrue((messageReceived!.header as! Dictionary)["testProp"] == "testval", "Expecting messageReceived.header.testProp == 'testval'")
        XCTAssertTrue(messageReceived!.body as! NSData == data, "Expecting messageReceived!.body == data")
        
        let xmlParser = XMLParser(data: (messageReceived!.body as! NSData) as Data)
        xmlParser.delegate = self
        xmlParser.parse()
        
        XCTAssertEqual(self.elementName!, "testMessage", "Expecting self.elementName! == 'testMessage'")
        XCTAssertEqual(self.testAtt!, "Hello", "Expecting self.testAtt == 'Hello'")
    }
    
    //xml parsing routine
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        self.elementName = elementName
        self.testAtt = attributeDict["testAtt"]
    }
    
    func callBackMethod(message: IPipeMessage) {
        self.messageReceived = message
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }

}
