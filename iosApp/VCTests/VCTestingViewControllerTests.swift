//
//  TestingClassUnitTests.swift
//  VCTests
//
//  Created by Nathan A on 4/20/23.
//

import XCTest
@testable import VC

class VCTestingViewControllerTests: XCTestCase {

    var sut: VCTestingViewController!

    override func setUpWithError() throws {
        sut = VCTestingViewController()
        sut.loadViewIfNeeded()
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func test_viewDidLoad_setsTitle() throws {
        XCTAssertEqual(sut.title, "Testing")
    }

    func test_viewDidLoad_setsBackgroundColor() throws {
        XCTAssertEqual(sut.view.backgroundColor, UIColor.systemBackground)
    }

    func test_sendMessageButtonTapped_instantiatesVCContactsViewControllerAndCallsTextMessageWithTwilio() throws {
        let mockVCContacts = MockVCContactsViewController()
        sut.addChild(mockVCContacts)

        sut.sendMessageButtonTapped()

        XCTAssertTrue(mockVCContacts.textMessageWithTwilioCalled)
    }

    func test_callButtonTapped_instantiatesVCContactsViewControllerAndCallsCallWithTwilio() throws {
        let mockVCContacts = MockVCContactsViewController()
        sut.addChild(mockVCContacts)

        sut.callButtonTapped()

        XCTAssertTrue(mockVCContacts.callWithTwilioCalled)
    }

    func test_countdownButtonTapped_setsCancelPressedAndNotificationSentToFalse_ifTheyWereTrue() throws {
        let mockCountdownVC = MockCountdownViewController()
        sut.countdownViewController = mockCountdownVC
        mockCountdownVC.cancelPressed = true
        mockCountdownVC.notificationSent = true

        sut.countdownButtonTapped()

        XCTAssertFalse(mockCountdownVC.cancelPressed)
        XCTAssertFalse(mockCountdownVC.notificationSent)
    }

    func test_countdownButtonTapped_callsShowCountdownUI() throws {
        let mockCountdownVC = MockCountdownViewController()
        sut.countdownViewController = mockCountdownVC

        sut.countdownButtonTapped()

        XCTAssertTrue(mockCountdownVC.showCountdownUICalled)
    }

    func test_voiceManagerButtonTapped_callsStartRecording() throws {
        let mockVoiceManager = MockVoiceManager()
        sut.voiceManager = mockVoiceManager

        sut.voiceManagerButtonTapped()

        XCTAssertTrue(mockVoiceManager.startRecordingCalled)
    }

}

class MockVCContactsViewController: VCContactsViewController {
    var textMessageWithTwilioCalled = false
    var callWithTwilioCalled = false

    override func textMessageWithTwilio() {
        textMessageWithTwilioCalled = true
    }

    override func callWithTwilio() {
        callWithTwilioCalled = true
    }
}

class MockCountdownViewController: CountdownViewController {
    var showCountdownUICalled = false

    override func showCountdownUI() {
        showCountdownUICalled = true
    }
}

class MockVoiceManager: VoiceManager {
    var startRecordingCalled = false

    override func startRecording() throws {
        startRecordingCalled = true
    }
}

