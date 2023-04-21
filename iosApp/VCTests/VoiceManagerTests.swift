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
    
    func testAuthorizationStatus() {
        voiceManager.requestAuthorization()
        XCTAssertNotEqual(SFSpeechRecognizer.authorizationStatus(), .notDetermined)
    }
    
    func testRecording() {
        XCTAssertNoThrow(try voiceManager.startRecording())
        voiceManager.stopRecording()
    }
    
    func testVoiceManager() {
        let voiceManager = VoiceManager()
        let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        
        // Test requestAuthorization
        voiceManager.requestAuthorization()
        
        // Test startRecording
        do {
            try voiceManager.startRecording()
        } catch {
            print("Error starting recording: \(error)")
        }
        
        // Test stopRecording
        voiceManager.stopRecording()
        
        // Test speechRecognizer availabilityDidChange delegate method
        voiceManager.speechRecognizer(speechRecognizer!, availabilityDidChange: true)
    }
}
