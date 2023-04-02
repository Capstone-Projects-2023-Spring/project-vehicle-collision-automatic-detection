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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Settings"
        
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        button.center = view.center
        button.setTitle("Test MSG", for: .normal)
        button.addTarget(self, action: #selector(sendMessageButtonTapped), for: .touchUpInside)
        view.addSubview(button)
        
        let button2 = UIButton(type: .system)
        button2.frame = CGRect(x: 0, y: button.frame.maxY + 20, width: 100, height: 50)
        button2.center.x = view.center.x
        button2.setTitle("Make Call", for: .normal)
        button2.addTarget(self, action: #selector(callButtonTapped), for: .touchUpInside)
        view.addSubview(button2)
        
        // Instantiate countdown view controller and add it as a child view controller
        countdownViewController = CountdownViewController()
        addChild(countdownViewController)
        countdownViewController.didMove(toParent: self)
        
        let button3 = UIButton(type: .system)
        button3.frame = CGRect(x: 0, y: button2.frame.maxY + 20, width: 100, height: 50)
        button3.center.x = view.center.x
        button3.setTitle("Countdown", for: .normal)
        button3.addTarget(self, action: #selector(countdownButtonTapped), for: .touchUpInside)
        view.addSubview(button3)
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
        countdownViewController.showCountdownUI()
    }
}
