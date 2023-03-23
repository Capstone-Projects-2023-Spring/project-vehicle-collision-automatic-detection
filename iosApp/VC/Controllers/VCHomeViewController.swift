//
//  VCHomeViewController.swift
//  VC
//
//  Created by Nathan A on 2/1/23.
//

import UIKit
import SwiftUI
import CoreBluetooth

/// Controller to show Home page
final class VCHomeViewController: UIViewController, BluetoothManagerDelegate {
    private var peripheralStatusLabel: UILabel!
    private let bluetoothManager = BluetoothManager()
    private var dataFromAdafruit: UILabel!
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
        dataFromAdafruit.text = "DEFAULT_DATA"
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
    }
    
    // When the Adafruit Bluefruit LE connects -> Change the connection status text & color to green
    func didConnectPeripheral() {
        peripheralStatusLabel.text = "Device connected"
        peripheralStatusLabel.textColor = UIColor.green
    }
    
    // When the Adafruit Bluefruit LE disconnects -> Change the connection status text & color back to red
    func didDisconnectPeripheral() {
        peripheralStatusLabel.text = "Device disconnected"
        peripheralStatusLabel.textColor = UIColor.red
    }
    
    func didReceiveData(_ data: Data) {
        // Convert the data to a string
        let receivedString = String(data: data, encoding: .utf8)
        // Update the label's text with the received string
        dataFromAdafruit.text = receivedString
        dataFromAdafruit.textColor = UIColor.black
    }

    
}
