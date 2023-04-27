//
//  VoiceManagerTests.swift
//  VCTests
//
//  Created by Thanh Nguyen on 4/20/23.
//

import XCTest
@testable import VC
import Speech

class VoiceManagerTests: XCTestCase {
    
    var voiceManager: VoiceManager!
    
    override func setUp() {
        super.setUp()
        voiceManager = VoiceManager()
    }
    
    func testRecording() {
        XCTAssertNoThrow(try voiceManager.startRecording())
        voiceManager.stopRecording()
    }
}
