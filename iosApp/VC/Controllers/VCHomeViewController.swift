//
//  VCHomeViewController.swift
//  VC
//
//  Created/Modified by Thanh N & Nathan A.
//

import UIKit
import SwiftUI
import CoreBluetooth

/// Controller to show Home page

final class VCHomeViewController: UIViewController, BluetoothManagerDelegate {
    private var peripheralStatusLabel: UILabel!
    private let bluetoothManager = BluetoothManager()
    private var dataFromAdafruit: UILabel!
    private var countdownViewController = CountdownViewController()
    /**
     This method is called after the view controller has loaded its view hierarchy into memory.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Connection Status"
        
        // Add a label to display the status of the peripheral
        peripheralStatusLabel = UILabel()
        peripheralStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        peripheralStatusLabel.text = "Device disconnected"
        peripheralStatusLabel.textColor = UIColor.red
        view.addSubview(peripheralStatusLabel)
        // Add a label for the data
        dataFromAdafruit = UILabel()
        dataFromAdafruit.translatesAutoresizingMaskIntoConstraints = false
        dataFromAdafruit.text = "0"
        dataFromAdafruit.textColor = UIColor.gray
        view.addSubview(dataFromAdafruit)
        
        NSLayoutConstraint.activate([
            peripheralStatusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            peripheralStatusLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20), // Position above dataFromAdafruit label
            dataFromAdafruit.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dataFromAdafruit.topAnchor.constraint(equalTo: peripheralStatusLabel.bottomAnchor, constant: 20) // Position below peripheralStatusLabel label
        ])
        
        // Start scanning for the peripheral device
        BluetoothManager.shared.delegate = self
        BluetoothManager.shared.startScanning()
        print("Device started in console")
        
//        //Fake retrieving data
//        let fakeData = "Fake data".data(using: .utf8)!
//        didReceiveData(fakeData)
        
        // Instantiate countdown view controller and add it as a child view controller
        countdownViewController = CountdownViewController()
        addChild(countdownViewController)
        countdownViewController.didMove(toParent: self)
    }
    
    // When the Adafruit Bluefruit LE connects -> Change the connection status text & color to green
    func didConnectPeripheral() {
        print("Device connected in console")
        peripheralStatusLabel.text = "Device connected"
        peripheralStatusLabel.textColor = UIColor.green
    }
    
    // When the Adafruit Bluefruit LE disconnects -> Change the connection status text & color back to red
    func didDisconnectPeripheral() {
        print("Device disconnected in console")
        peripheralStatusLabel.text = "Device disconnected"
        peripheralStatusLabel.font = UIFont.systemFont(ofSize: 20)
        peripheralStatusLabel.textColor = UIColor.red
    }
    
    func didReceiveData(_ data: Data) {
        print("Device received data from Adafruit Bluefruit LE")
        // Convert the data to a string
        let receivedString = String(data: data, encoding: .utf8)
        // Update the label's text with the received string
        dataFromAdafruit.text = receivedString
        dataFromAdafruit.font = UIFont.systemFont(ofSize: 18)
        dataFromAdafruit.textColor = UIColor.blue
        
        // Check cancel isn't pressed from previous runs 
        if countdownViewController.cancelPressed || countdownViewController.notificationSent {
            countdownViewController.cancelPressed = false
            countdownViewController.notificationSent = false
        }
        countdownViewController.showCountdownUI()
    }
}
