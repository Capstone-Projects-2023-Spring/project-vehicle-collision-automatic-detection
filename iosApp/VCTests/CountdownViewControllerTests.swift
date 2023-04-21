//
//  CountdownViewControllerTests.swift
//  VCTests
//
//  Created by Thanh Nguyen on 4/20/23.
//

import XCTest
@testable import VC

class CountdownViewControllerTests: XCTestCase {
    
    var countdownViewController: CountdownViewController!
    
    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        countdownViewController = storyboard.instantiateViewController(withIdentifier: "CountdownViewController") as? CountdownViewController
        countdownViewController.loadViewIfNeeded()
    }
    
    override func tearDown() {
        countdownViewController = nil
        super.tearDown()
    }
    
    func testCountdownUI() {
        countdownViewController.showCountdownUI()
        
        // Assert that the countdown timer is started
        XCTAssertTrue(countdownViewController.countdownTimer != nil)
        
        // Simulate countdown timer reaching 0
        countdownViewController.cancelPressed = false
        countdownViewController.notificationSent = false
        countdownViewController.countdownTimer?.fire()
        
        // Assert that the notification is sent when the countdown timer reaches 0
        XCTAssertTrue(countdownViewController.notificationSent)
    }
    
    func testCancelAction() {
        countdownViewController.showCountdownUI()
        
        // Simulate the user pressing the cancel button
        countdownViewController.cancelPressed = true
        countdownViewController.countdownTimer?.fire()
        
        // Assert that the audio player is stopped and the view controller is dismissed
        XCTAssertTrue(countdownViewController.audioPlayer?.isPlaying == false)
        XCTAssertTrue(countdownViewController.presentedViewController == nil)
    }
}
