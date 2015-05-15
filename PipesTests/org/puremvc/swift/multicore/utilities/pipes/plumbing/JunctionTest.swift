//
//  JunctionTest.swift
//  PureMVC SWIFT/MultiCore Utility – Pipes
//
//  Copyright(c) 2015-2025 Saad Shams <saad.shams@puremvc.org>
//  Your reuse is governed by the Creative Commons Attribution 3.0 License
//

import Pipes
import XCTest

/**
Test the Junction class.
*/
class JunctionTest: XCTestCase {

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
    Test registering an INPUT pipe to a junction.
    
    Tests that the INPUT pipe is successfully registered and
    that the hasPipe and hasInputPipe methods work. Then tests
    that the pipe can be retrieved by name.
    
    Finally, it removes the registered INPUT pipe and tests
    that all the previous assertions about it's registration
    and accessability via the Junction are no longer true.
    */
    func testRegisterRetrieveAndRemoveInputPipe() {
        // create pipe connected to this test with a pipelistener
        var pipe: IPipeFitting = Pipe()
        
        // create junction
        var junction = Junction()
        
        // register the pipe with the junction, giving it a name and direction
        var registered = junction.registerPipe("testInputPipe", type: Junction.INPUT, pipe: pipe)
        
        // test assertions
        XCTAssertNotNil(pipe is Pipe, "Expecting pipe is Pipe")
        XCTAssertNotNil(junction as Junction, "Expecting junction is Junction")
        XCTAssertTrue(registered, "Expecting success registering pipe")
        
        // assertions about junction methods once input  pipe is registered
        XCTAssertTrue(junction.hasPipe("testInputPipe"), "Expecting junction has pipe")
        XCTAssertTrue(junction.hasInputPipe("testInputPipe"), "Expecgint junction has pipe registered as an Input pipe")
        XCTAssertTrue(junction.retrievePipe("testInputPipe") as! Pipe === pipe as! Pipe, "Expecting pipe retrieved from junction")
        
        // now remove the pipe and be sure that it is no longer there (same assertions should be false)
        junction.removePipe("testInputPipe")
        XCTAssertFalse(junction.hasPipe("testInputPipe"), "Expecting junction has no pipe")
        XCTAssertFalse(junction.hasInputPipe("testInputPipe"), "Expecting Junction has no pipe registered as Input pipe")
        XCTAssertNil(junction.retrievePipe("testInputPipe") as? Pipe, "Expecting pipe retrieved from junction as nil")
    }
    
    /**
    Test registering an OUTPUT pipe to a junction.
    
    Tests that the OUTPUT pipe is successfully registered and
    that the hasPipe and hasOutputPipe methods work. Then tests
    that the pipe can be retrieved by name.
    
    Finally, it removes the registered OUTPUT pipe and tests
    that all the previous assertions about it's registration
    and accessability via the Junction are no longer true.
 		 */
    func testRegisterRetrieveAndRemoveOutputPipe() {
        // create pipe connected to this test with a pipelistener
        var pipe: IPipeFitting = Pipe()
        
        // create junction
        var junction = Junction()
        
        // register the pipe with the junction, giving it a name and direction
        var registered = junction.registerPipe("testOutputPipe", type: Junction.OUTPUT, pipe: pipe)
        
        // test assertions
        XCTAssertNotNil(pipe is Pipe, "Expecting pipe is Pipe")
        XCTAssertNotNil(junction as Junction, "Expecting junction is Junction")
        XCTAssertTrue(registered, "Expecting success registering pipe")
        
        // assertions about junction methods once output pipe is registered
        XCTAssertTrue(junction.hasPipe("testOutputPipe"), "Expecting junction has pipe")
        XCTAssertTrue(junction.hasOutputPipe("testOutputPipe"), "Expecting junction has pipe registered as an OUTPUT type")
        XCTAssertTrue(junction.retrievePipe("testOutputPipe") as! Pipe === pipe as! Pipe, "Expecting pipe retrieved from junction")
        
        // now remove the pipe and be sure that it is no longer there (same assertions should be false)
        junction.removePipe("testOutputPipe")
        XCTAssertFalse(junction.hasPipe("testOutputPipe"), "Expecting junction no longer has pipe")
        XCTAssertFalse(junction.hasOutputPipe("testOutputPipe"), "Expecting junction no longer has pipe registered as OUTPUT type")
        XCTAssertNil(junction.retrievePipe("testOutputPipe") as? Pipe, "Expecting pipe can't be retrieved from junction")
    }
    
    /**
    Test adding a PipeListener to an Input Pipe.
    
    Registers an INPUT Pipe with a Junction, then tests
    the Junction's addPipeListener method, connecting
    the output of the pipe back into to the test. If this
    is successful, it sends a message down the pipe and
    checks to see that it was received.
    */
    func testAddingPipeListenerToAnInputPipe() {
        // create pipe
        var pipe: IPipeFitting = Pipe()
        
        // create junction
        var junction: Junction = Junction()
        
        // create test message
        var message: IPipeMessage = Message(type: Message.NORMAL, body: ["testVal" : 1])
        
        // register the pipe with the junction, giving it a name and direction
        var registered = junction.registerPipe("testInputPipe", type: Junction.INPUT, pipe: pipe)
        
        // add the pipelistener using the junction method
        var listenerAdded = junction.addPipeListener("testInputPipe", context: self, listener: self.callBackMethod)
        
        // send the message using our reference to the pipe,
        // it should show up in messageReceived property via the pipeListener
        var sent: Bool = pipe.write(message)
        
        // test assertions
        XCTAssertNotNil(pipe is Pipe, "Expecting pipe is Pipe")
        XCTAssertNotNil(junction as Junction, "Expecting junction is Junction")
        XCTAssertTrue(registered, "Expecting registered pipe")
        XCTAssertTrue(listenerAdded, "Expecting added pipeListener")
        XCTAssertTrue(sent, "Expecting successful write to pipe")
        XCTAssertTrue(messagesReceived.count == 1, "Expecting 1 message received")
        XCTAssertTrue(messagesReceived.removeAtIndex(0) as! Message === message as! Message, "Expecting received message was same instance sent")
    }
    
    /**
    Test using sendMessage on an OUTPUT pipe.
    
    Creates a Pipe, Junction and Message.
    Adds the PipeListener to the Pipe.
    Adds the Pipe to the Junction as an OUTPUT pipe.
    uses the Junction's sendMessage method to send
    the Message, then checks that it was received.
    */
    func testSendMessageOnAnOutputPipe() {
        // create pipe
        var pipe: IPipeFitting = Pipe()
        
        // add a PipeListener manually
        var listenerAdded = pipe.connect(PipeListener(context: self, listener: self.callBackMethod))
        
        // create junction
        var junction = Junction()
        
        // create test message
        var message: IPipeMessage = Message(type: Message.NORMAL, body: ["testVal": 1])
        
        // register the pipe with the junction, giving it a name and direction
        var registered = junction.registerPipe("testOutputPipe", type: Junction.OUTPUT, pipe: pipe)
        
        // send the message using the Junction's method
        // it should show up in messageReceived property via the pipeListener
        var sent: Bool  = junction.sendMessage("testOutputPipe", message: message)
        
        // test assertions
        XCTAssertNotNil(pipe as! Pipe, "Expecting pipe is Pipe")
        XCTAssertNotNil(junction as Junction, "Expecting junction is Junction")
        XCTAssertTrue(registered, "Expecting registered pipe")
        XCTAssertTrue(listenerAdded, "Expecting added pipeListener")
        XCTAssertTrue(sent, "Expecting message sent")
        XCTAssertTrue(messagesReceived.count == 1, "Expecting 1 message received")
        XCTAssertTrue(messagesReceived.removeAtIndex(0) as! Message === message as! Message, "Expecting received message was same instance sent")
    }
    
    /**
    Callback given to `PipeListener` for incoming message.
    
    Used by `testReceiveMessageViaPipeListener`
    to get the output of pipe back into this  test to see
    that a message passes through the pipe.
    */
    func callBackMethod(message: IPipeMessage) {
        messagesReceived.append(message)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
