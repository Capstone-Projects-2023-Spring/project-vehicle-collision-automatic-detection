//
//  VCSettingViewController.swift
//  VC
//
//  Created by Nathan A on 2/1/23.
//

import UIKit
import SwiftUI
import MobileCoreServices

/// Controller to view and change the application's settings
final class VCSettingViewController: UIViewController {
    @objc func sendMessageButtonTapped() {
        let vcContacts = VCContactsViewController()
        vcContacts.textMessageWithTwilio()
    }
    
    @objc func callButtonTapped() {
        let vcContacts = VCContactsViewController()
        vcContacts.callWithTwilio()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        title = "Settings"
        // Do any additional setup after loading the view.
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
    }
}
