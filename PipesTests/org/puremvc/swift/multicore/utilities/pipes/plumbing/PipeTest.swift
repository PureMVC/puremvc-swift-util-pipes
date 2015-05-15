//
//  PipeTest.swift
//  PureMVC SWIFT/MultiCore Utility – Pipes
//
//  Copyright(c) 2015-2025 Saad Shams <saad.shams@puremvc.org>
//  Your reuse is governed by the Creative Commons Attribution 3.0 License
//

import Pipes
import XCTest

/**
Test the Pipe class.
*/
class PipeTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    /**
    * Test the constructor.
    */
    func testConstructor() {
        var pipe = Pipe()
        
        // test assertions
        XCTAssertNotNil(pipe, "Expecting pipe is not nil")
    }
    
    /**
    Test connecting and disconnecting two pipes.
    */
    func testConnectingAndDisconnectingTwoPipes() {
        // create two pipes
        var pipe1: IPipeFitting = Pipe()
        var pipe2: IPipeFitting = Pipe()
        // connect them
        var success = pipe1.connect(pipe2)
        
        // test assertions
        XCTAssertNotNil(pipe1 as! Pipe, "Expecting pipe1 is Pipe")
        XCTAssertNotNil(pipe2 as! Pipe, "Expecting pipe2 is Pipe")
        XCTAssertNotNil(success, "Expecting connected pipe1 to pipe2")
        
        // disconnect pipe 2 from pipe 1
        var disconnectedPipe: IPipeFitting = pipe1.disconnect()!
        XCTAssertTrue(disconnectedPipe as! Pipe === pipe2 as! Pipe, "Expecting disconnected pipe2 from pipe1")
    }
    
    /**
    Test attempting to connect a pipe to a pipe with an output already connected.
    */
    func testConnectingToAConnectedPipe() {
        // create three pipes
        var pipe1: IPipeFitting = Pipe()
        var pipe2: IPipeFitting = Pipe()
        var pipe3: IPipeFitting = Pipe()
        
        // connect them
        var success: Bool = pipe1.connect(pipe2)
        
        // test assertions
        XCTAssertTrue(success, "Expecting connected pipe1 to pipe2")
        XCTAssertTrue(pipe1.connect(pipe3) == false, "Expecting can't connect pipe3 to pipe1")
    }
    
    func testWriteEmptyPipe() {
        var pipe = Pipe()
        pipe.write(Message(type: "Nil", header: nil, body: nil, priority: 0)) //shouldn't crash the program
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
