//
//  MessageTest.swift
//  PureMVC SWIFT/MultiCore Utility – Pipes
//
//  Copyright(c) 2015-2019 Saad Shams <saad.shams@puremvc.org>
//  Your reuse is governed by the Creative Commons Attribution 3.0 License
//

import XCTest
@testable import Pipes

/**
Test the Message class.
*/
class MessageTest: XCTestCase, XMLParserDelegate {

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
    Tests the constructor parameters and getters.
    */
    func testConstructorAndGetters() {
        let data = "<testMessage testAtt='Hello' />".data(using: String.Encoding.utf8, allowLossyConversion: false)
        
        // create a message with complete constructor args
        let message: IPipeMessage = Message(type: Message.NORMAL, header: ["testProp": "testval"], body: data, priority: Message.PRIORITY_HIGH)
        
        let parser = XMLParser(data: data!)
        parser.delegate = self
        parser.parse()
        
        // test assertions
        XCTAssertNotNil(message is Message, "message is Message")
        XCTAssertTrue(message.type == Message.NORMAL, "Expecting message.type == Message.NORMAL")
        XCTAssertTrue((message.header as! Dictionary)["testProp"]  == "testval", "Expecting Message.header['testProp'] == 'testval'")
        XCTAssertTrue(self.testAtt == "Hello", "Expecting self.testAtt == 'Hello'")
        XCTAssertTrue(message.priority == Message.PRIORITY_HIGH, "Expecting message.priority == Message.PRIORITY_HIGH")
    }
    
    /**
    Tests message default priority.
    */
    func testDefaultPriority() {
        // Create a message with minimum constructor args
        var message: IPipeMessage = Message(type: Message.NORMAL)
        
        // test assertions
        XCTAssertTrue(message.priority == Message.PRIORITY_MED, "Expecting message.priority == Message.PRIORITY_MED")
        
        message = Message(type: Message.NORMAL, body: "")
        XCTAssertTrue(message.priority == Message.PRIORITY_MED, "Expecting message.priority == Message.PRIORITY_MED")
        
        message = Message(type: Message.NORMAL, header: "")
        XCTAssertTrue(message.priority == Message.PRIORITY_MED, "Expecting message.priority == Message.PRIORITY_MED")
    }
    
    /**
    Tests the setters and getters.
    */
    func testSettersAndGetters() {
        var message: IPipeMessage = Message(type: Message.NORMAL)
        
        message.header = ["testProp": "testval"]
        
        let data = "<testMessage testAtt='Hello' />".data(using: String.Encoding.utf8, allowLossyConversion: false)
        message.body = data
        message.priority = Message.PRIORITY_LOW
        
        let parser = XMLParser(data: (message.body as! NSData) as Data)
        parser.delegate = self
        parser.parse()
        
        XCTAssertNotNil(message is Message, "Expecting message is Message")
        XCTAssertTrue(message.type == Message.NORMAL, "Expecting message.thype == Message.NORMAL")
        XCTAssertTrue((message.header as! Dictionary)["testProp"] == "testval", "Expecting message.header['testProp'] == 'testval'")
        XCTAssertEqual(self.elementName!, "testMessage", "")
        XCTAssertEqual(self.testAtt!, "Hello", "Expecting message.body['testAtt'] == 'testval'")
        XCTAssertTrue(message.priority == Message.PRIORITY_LOW, "Expecting message.priority == Message.PRIORITY_LOW")
    }
    
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        self.elementName = elementName
        self.testAtt = attributeDict["testAtt"]
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }

}
