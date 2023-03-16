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
final class VCHomeViewController: UIViewController, BluetoothManagerDelegate{
    let bluetoothManager = BluetoothManager()
    private var peripheralStatusLabel: UILabel!
    
    /**
     This method is called after the view controller has loaded its view hierarchy into memory.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Home"
        bluetoothManager.delegate = self
        
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
    }
    func didConnectPeripheral() {
        peripheralStatusLabel.text = "Device connected"
        peripheralStatusLabel.textColor = UIColor.red
    }
    
    func didDisconnectPeripheral() {
        peripheralStatusLabel.text = "Device disconnected"
        peripheralStatusLabel.textColor = UIColor.green
    }
}
