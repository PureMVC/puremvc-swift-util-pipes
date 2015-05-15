//
//  QueueTest.swift
//  PureMVC SWIFT/MultiCore Utility – Pipes
//
//  Copyright(c) 2015-2025 Saad Shams <saad.shams@puremvc.org>
//  Your reuse is governed by the Creative Commons Attribution 3.0 License
//

import Pipes
import XCTest

/**
Test the Queue class.
*/
class QueueTest: XCTestCase {

    /**
    Array of received messages.
    
    Used by `callBackMedhod` as a place to store the recieved messages.
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
    Test connecting input and output pipes to a queue.
    */
    func testConnectingIOPipes() {
        // create output pipes 1
        var pipe1: IPipeFitting = Pipe()
        var pipe2: IPipeFitting = Pipe()
        
        // create queue
        var queue: Pipe = Queue()
        
        // connect input fitting
        var connectInput = pipe1.connect(queue)
        
        // connect output fitting
        var connectedOutput = queue.connect(pipe2)
        
        // test assertions
        XCTAssertNotNil(pipe1 as! Pipe, "Expecting pipe1 is Pipe")
        XCTAssertNotNil(pipe1 as! Pipe, "Expecting pipe2 is Pipe")
        XCTAssertNotNil(queue as! Queue, "Queue is Queue")
        XCTAssertTrue(connectInput, "Expecting connected input")
        XCTAssertTrue(connectedOutput, "Expecting connected output")
    }
    
    /**
    Test writing multiple messages to the Queue followed by a Flush message.
    
    Creates messages to send to the queue.
    Creates queue, attaching an anonymous listener to its output. 
    Writes messages to the queue. Tests that no messages have been 
    received yet (they've been enqueued). Sends FLUSH message. Tests 
    that messages were receieved, and in the order sent (FIFO).
    */
    func testWritingMultipleMessagesAndFlush() {
        // create messages to send to the queue
        var message1 = Message(type: Message.NORMAL, header: ["testProp": 1])
        var message2 = Message(type: Message.NORMAL, header: ["testProp": 2])
        var message3 = Message(type: Message.NORMAL, header: ["testProp": 3])
        
        // create queue control flush message
        var flush: IPipeMessage = QueueControlMessage(type: QueueControlMessage.FLUSH)
        
        // create queue, attaching an anonymous listener to its output
        var queue = Queue(output: PipeListener(context: self, listener: callBackMethod))
        
        // write messages to the queue
        var message1Written = queue.write(message1)
        var message2Written = queue.write(message2)
        var message3Written = queue.write(message3)
        
        // test assertions
        XCTAssertNotNil(message1 as Message, "Expecting message1 as Message")
        XCTAssertNotNil(message2 as Message, "Expecting message2 as Message")
        XCTAssertNotNil(message3 as Message, "Expecting message3 as Message")
        XCTAssertNotNil(flush as! Message, "Expecting flush is Message")
        
        XCTAssertTrue(message1Written, "Expecting wrote message1 to queue")
        XCTAssertTrue(message2Written, "Expecting wrote message2 to queue")
        XCTAssertTrue(message3Written, "Expecting wrote message3 to queue")
        
        // test that no messages were received (they've been enqueued)
        XCTAssertTrue(messagesReceived.count == 0, "Expecting received 0 messages")
        
        // write flush control message to the queue
        var flushWritten = queue.write(flush)
        
        // test that all messages were received, then test
        // FIFO order by inspecting the messages themselves
        XCTAssertTrue(messagesReceived.count == 3, "Expecting received 3 messages")
        
        // test message 1 assertions
        var received1 = messagesReceived.removeAtIndex(0)
        XCTAssertNotNil(received1 as! Message, "Expecting received1 as Message")
        XCTAssertTrue(received1 as! Message === message1 as Message, "Expecting received1 === message")
        
        // test message 2 assertions
        var received2 = messagesReceived.removeAtIndex(0)
        XCTAssertNotNil(received2 as! Message, "Expecting received2 as Message")
        XCTAssertTrue(received2 as! Message === message2 as Message, "Expecting received2 === message")
        
        // test message 3 assertions
        var received3 = messagesReceived.removeAtIndex(0)
        XCTAssertNotNil(received3 as! Message, "Expecting received3 as Message")
        XCTAssertTrue(received3 as! Message === message3 as Message, "Expecting received3 === message")
    }
    
    /**
    Test the Sort-by-Priority and FIFO modes.
    
    Creates messages to send to the queue, priorities unsorted.
    Creates queue, attaching an anonymous listener to its output.
    Sends SORT message to start sort-by-priority order mode.
    Writes messages to the queue. Sends FLUSH message, tests
    that messages were receieved in order of priority, not how
    they were sent.
    
    Then sends a FIFO message to switch the queue back to
    default FIFO behavior, sends messages again, flushes again,
    tests that the messages were recieved and in the order they
    were originally sent.
    */
    func testSortByPriorityAndFIFO() {
        // create messages to send to the queue
        var message1 = Message(type: Message.NORMAL, header: nil, body: nil, priority: Message.PRIORITY_MED)
        var message2 = Message(type: Message.NORMAL, header: nil, body: nil, priority: Message.PRIORITY_LOW)
        var message3 = Message(type: Message.NORMAL, header: nil, body: nil, priority: Message.PRIORITY_HIGH)
        
        // create queue, attaching an anonymous listener to its output
        var queue = Queue(output: PipeListener(context: self, listener: callBackMethod))
        
        // begin sort-by-priority order mode
        var sortWritten = queue.write(QueueControlMessage(type: QueueControlMessage.SORT))
        
        // write messages to the queue
        var message1Written = queue.write(message1)
        var message2Written = queue.write(message2)
        var message3Written = queue.write(message3)
        
        // flush the queue
        var flushWritten = queue.write(QueueControlMessage(type: QueueControlMessage.FLUSH))
        
        // test assertions
        XCTAssertTrue(sortWritten, "Expecting wrote sort message to queue")
        XCTAssertTrue(message1Written, "Expecting wrote message1 to queue")
        XCTAssertTrue(message2Written, "Expecting wrote message2 to queue")
        XCTAssertTrue(message3Written, "Expecting wrote message3 to queue")
        
        // test that 3 messages were received
        XCTAssertTrue(messagesReceived.count == 3, "Expecting received 3 messages")
        
        // get the messages
        var received1 = messagesReceived.removeAtIndex(0)
        var received2 = messagesReceived.removeAtIndex(0)
        var received3 = messagesReceived.removeAtIndex(0)
        
        // test that the message order is sorted
        XCTAssertTrue(received1.priority < received2.priority, "Expecting received1 is higher priority than received 2")
        XCTAssertTrue(received2.priority < received3.priority, "Expecting received2 is higher priority than received 3")
        XCTAssertTrue(received1 as! Message === message3 as Message, "Expecting received1 === message3")
        XCTAssertTrue(received2 as! Message === message1 as Message, "Expecting received2 === message1")
        XCTAssertTrue(received3 as! Message === message2 as Message, "Expecting received3 === message2")
        
        // begin FIFO order mode
        var fifoWritten = queue.write(QueueControlMessage(type: QueueControlMessage.FIFO))
        
        // write messages to the queue
        var message1writtenAgain = queue.write(message1)
        var message2writtenAgain = queue.write(message2)
        var message3writtenAgain = queue.write(message3)
        
        // flush the queue
        var flushWrittenAgain = queue.write(QueueControlMessage(type: QueueControlMessage.FLUSH))
        
        // test assertions
        XCTAssertTrue(fifoWritten, "Expecting wrote fifo message to queue")
        XCTAssertTrue(message1writtenAgain, "Expecting wrote message1 to queue again")
        XCTAssertTrue(message2writtenAgain, "Expecting wrote message2 to queue again")
        XCTAssertTrue(message3writtenAgain, "Expecting wrote message3 to queue again")
        XCTAssertTrue(flushWrittenAgain, "Expecting wrote flush message to queue again")
        
        // test that 3 messages were received
        XCTAssertTrue(messagesReceived.count == 3, "Expecting received 3 messages")
        
        // get the messages
        var received1Again = messagesReceived.removeAtIndex(0)
        var received2Again = messagesReceived.removeAtIndex(0)
        var received3Again = messagesReceived.removeAtIndex(0)
        
        // test message order is FIFO
        XCTAssertNotNil(received1Again as! Message === message1 as Message, "Expecting received1Again === message1")
        XCTAssertNotNil(received2Again as! Message === message2 as Message, "Expecting received2Again === message2")
        XCTAssertNotNil(received3Again as! Message === message3 as Message, "Expecting received3Again === message3")
        XCTAssertTrue(received1Again.priority == Message.PRIORITY_MED, "Expecting received1Again is priority med")
        XCTAssertTrue(received2Again.priority == Message.PRIORITY_LOW, "Expecting received2Again is priority low")
        XCTAssertTrue(received3Again.priority == Message.PRIORITY_HIGH, "Expecting received3Again is priority high")
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
