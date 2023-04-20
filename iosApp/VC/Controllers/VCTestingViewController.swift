//
//  VCTestingViewController.swift
//  VC
//
//  Created/Modified by Thanh N & Nathan A.
//

import UIKit
import SwiftUI
import MobileCoreServices

/// Controller to view and change the application's settings
final class VCTestingViewController: UIViewController {
    var countdownViewController = CountdownViewController()
    var voiceManager = VoiceManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Testing"
        
        let textMsgButton = UIButton(type: .custom)
        textMsgButton.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        textMsgButton.center = view.center
        textMsgButton.setTitle("Test MSG", for: .normal)
        textMsgButton.setTitleColor(.white, for: .normal)
        textMsgButton.backgroundColor = .systemBlue
        textMsgButton.layer.cornerRadius = 10
        textMsgButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        textMsgButton.addTarget(self, action: #selector(sendMessageButtonTapped), for: .touchUpInside)
        view.addSubview(textMsgButton)

        let makeCallButton = UIButton(type: .custom)
        makeCallButton.frame = CGRect(x: 0, y: textMsgButton.frame.maxY + 20, width: 100, height: 50)
        makeCallButton.center.x = view.center.x
        makeCallButton.setTitle("Make Call", for: .normal)
        makeCallButton.setTitleColor(.white, for: .normal)
        makeCallButton.backgroundColor = .systemBlue
        makeCallButton.layer.cornerRadius = 10
        makeCallButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        makeCallButton.addTarget(self, action: #selector(callButtonTapped), for: .touchUpInside)
        view.addSubview(makeCallButton)
        
        let voiceTestButton = UIButton(type: .custom)
        voiceTestButton.frame = CGRect(x: 0, y: makeCallButton.frame.maxY + 20, width: 100, height: 50)
        voiceTestButton.center.x = view.center.x
        voiceTestButton.setTitle("Voice Test", for: .normal)
        voiceTestButton.setTitleColor(.white, for: .normal)
        voiceTestButton.backgroundColor = .systemBlue
        voiceTestButton.layer.cornerRadius = 10
        voiceTestButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        voiceTestButton.addTarget(self, action: #selector(voiceManagerButtonTapped), for: .touchUpInside)
        view.addSubview(voiceTestButton)

        // Instantiate countdown view controller and add it as a child view controller
        countdownViewController = CountdownViewController()
        addChild(countdownViewController)
        countdownViewController.didMove(toParent: self)

        let startCountDownButton = UIButton(type: .custom)
        startCountDownButton.frame = CGRect(x: 0, y: voiceTestButton.frame.maxY + 20, width: 100, height: 50)
        startCountDownButton.center.x = view.center.x
        startCountDownButton.setTitle("Countdown", for: .normal)
        startCountDownButton.setTitleColor(.white, for: .normal)
        startCountDownButton.backgroundColor = .systemBlue
        startCountDownButton.layer.cornerRadius = 10
        startCountDownButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        startCountDownButton.addTarget(self, action: #selector(countdownButtonTapped), for: .touchUpInside)
        view.addSubview(startCountDownButton)
    }
    
    @objc func sendMessageButtonTapped() {
        let vcContacts = VCContactsViewController()
        vcContacts.textMessageWithTwilio()
    }
    
    @objc func callButtonTapped() {
        let vcContacts = VCContactsViewController()
        vcContacts.callWithTwilio()
    }
    
    @objc func countdownButtonTapped() {
        if countdownViewController.cancelPressed || countdownViewController.notificationSent {
            countdownViewController.cancelPressed = false
            countdownViewController.notificationSent = false
        }
        countdownViewController.showCountdownUI()
    }
    
    @objc func voiceManagerButtonTapped() {
        let vcVoice = VoiceManager()
        do {
            try vcVoice.startRecording()
        } catch let error {
            print("Error starting recording: \(error.localizedDescription)")
        }
    }

}
