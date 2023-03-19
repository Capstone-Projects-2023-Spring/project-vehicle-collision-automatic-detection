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
        
        NSLayoutConstraint.activate([
            peripheralStatusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            peripheralStatusLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Start scanning for the peripheral device
        BluetoothManager.shared.delegate = self
        BluetoothManager.shared.startScanning()
    }
    
    func didConnectPeripheral() {
        peripheralStatusLabel.text = "Device connected"
        peripheralStatusLabel.textColor = UIColor.green
    }
    
    func didDisconnectPeripheral() {
        peripheralStatusLabel.text = "Device disconnected"
        peripheralStatusLabel.textColor = UIColor.red
    }
}
