//
//  CountdownViewController.swift
//  VC
//
//  Created/Modified by Thanh N & Nathan A.
//

import Foundation
import UIKit
import SwiftUI
import AVFoundation

class CountdownViewController: UIViewController {
    
    private var countdownTimer: Timer?
    public var cancelPressed = false
    public var notificationSent = false
    private var audioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func showCountdownUI() {
        // Play Alarm Sound
        setUpSound()
        audioPlayer?.play()
        // Active Voice Recognition
        let voiceManager = VoiceManager()
        do {
            try voiceManager.startRecording()
        } catch let error {
            print("Error starting recording: \(error.localizedDescription)")
        }
        let countDownTitle = "Crash Detected!"
        let countDownMessage = "\nTo cancel automatic notifications, press or say 'Cancel'"
        let alertController = UIAlertController(title: countDownTitle, message: countDownMessage, preferredStyle: .alert)
        
        // Change countDownTitle attributes
        if let titleString = countDownTitle as? NSString {
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor(named: "CountDownColor") as Any,
                .font: UIFont.boldSystemFont(ofSize: 30)
            ]
            let attributedTitle = NSAttributedString(string: titleString as String, attributes: attributes)
            alertController.setValue(attributedTitle, forKey: "attributedTitle")
        }
        
        // Change countDownMessage color and font size
        if let messageString = countDownMessage as? NSString {
            let attributes = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)
            ]
            let attributedMessage = NSAttributedString(string: messageString as String, attributes: attributes)
            alertController.setValue(attributedMessage, forKey: "attributedMessage")
        }
        
        // Add text label
        let countDownTextLabel = UILabel()
        countDownTextLabel.font = UIFont.systemFont(ofSize: 16)
        countDownTextLabel.textAlignment = .center
        countDownTextLabel.text = "Time Until Emergency Alerts"
        alertController.view.addSubview(countDownTextLabel)
        countDownTextLabel.translatesAutoresizingMaskIntoConstraints = false
        countDownTextLabel.centerXAnchor.constraint(equalTo: alertController.view.centerXAnchor).isActive = true
        countDownTextLabel.bottomAnchor.constraint(equalTo: alertController.view.centerYAnchor, constant: 20).isActive = true
        
        // Create the countdown label and add it to the alert controller
        let countDownLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        countDownLabel.font = UIFont.systemFont(ofSize: 40)
        countDownLabel.textColor = UIColor(named: "CountDownColor")
        countDownLabel.textAlignment = .center
        countDownLabel.text = "10"
        alertController.view.addSubview(countDownLabel)
        countDownLabel.translatesAutoresizingMaskIntoConstraints = false
        countDownLabel.centerXAnchor.constraint(equalTo: alertController.view.centerXAnchor).isActive = true
        countDownLabel.centerYAnchor.constraint(equalTo: alertController.view.centerYAnchor, constant: 60).isActive = true
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.cancelPressed = true
            self?.audioPlayer?.stop()
            self?.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(cancelAction)
        
        // Start the countdown timer
        var countdownSeconds = 10
        let countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            countdownSeconds -= 1
            countDownLabel.text = "\(countdownSeconds)"
            
            // Change to text color to red
            if countdownSeconds <= 3 {
                if let titleString = countDownTitle as? NSString {
                    let attributes: [NSAttributedString.Key: Any] = [
                        .foregroundColor: UIColor.red,
                        .font: UIFont.boldSystemFont(ofSize: 30)
                    ]
                    let attributedTitle = NSAttributedString(string: titleString as String, attributes: attributes)
                    alertController.setValue(attributedTitle, forKey: "attributedTitle")
                }
                countDownLabel.textColor = .red
            }
            
            // Exit loop
            if self.cancelPressed || voiceManager.voiceDetected == true {
                self.audioPlayer?.stop()
                countdownSeconds = 0
                timer.invalidate()
                self.dismiss(animated: true, completion: nil)
            }
            
            // Notify Emergency Contacts
            else if countdownSeconds == 0 {
                self.audioPlayer?.stop()
                timer.invalidate()
                if !self.cancelPressed && !self.notificationSent {
                    let vcContact = VCContactsViewController()
                    vcContact.textMessageWithTwilio()
                    vcContact.callWithTwilio()
                    self.notificationSent = true
                }
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        // Store the countdown timer in a property so it can be invalidated if necessary
        self.countdownTimer = countdownTimer
        
        
        // Set the alert controller's height and width
        let height: NSLayoutConstraint = NSLayoutConstraint(item: alertController.view!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 350)
        let width:NSLayoutConstraint = NSLayoutConstraint(item: alertController.view!, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 500)
        alertController.view.addConstraint(height)
        alertController.view.addConstraint(width)
        
        // Present the alert controller
        present(alertController, animated: true, completion: nil)
    }
    
    private func setUpSound() {
        // Setup sound
        guard let path = Bundle.main.path(forResource: "audiomass-output", ofType: "mp3") else {
            return
        }
        let url = URL(fileURLWithPath: path)
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
        } catch {
            // Error handling
        }
    }
}
