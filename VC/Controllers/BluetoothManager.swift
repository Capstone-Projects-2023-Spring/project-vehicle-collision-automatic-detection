//
//  BluetoothManager.swift
//  VC
//
//  Created by Thanh Nguyen on 3/11/23.
//

import CoreBluetooth
import UIKit

// Bluetooth LE
class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            // Bluetooth is ready to use
        } else {
            // Bluetooth is not available
        }
    }
    
    // Scan for nearby peripheral devices using the CBCentralManager's scanForPeripherals.
    func startScanning() {
        centralManager.scanForPeripherals(withServices: [BLEServiceUUID], options: nil)
    }

    let BLEServiceUUID = CBUUID(string: "YOUR_SERVICE_UUID")
    
    // Connect to the desired peripheral device using the CBCentralManager.
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name == "YOUR_DEVICE_NAME" {
            centralManager.stopScan()
            self.peripheral = peripheral
            self.peripheral.delegate = self
            centralManager.connect(peripheral, options: nil)
        }
    }
    
    // Once the connection is established.
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices([BLEServiceUUID])
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            print(characteristic.uuid)
            // Handle the available characteristics as needed
        }
    }
    
    // Read/Write/Handle the data
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        /*//When ready to handle data uncomment this
        guard let data = characteristic.value else { return }
        // Handle the received data as needed
        */
        
        // This is boolean statement, just a placeholder
        guard characteristic.value != nil else { return }
    }
    
    /*
    func writeToCharacteristic(data: Data) {
        guard let characteristic = self.characteristic else { return }
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }
    */

}

/*
// Normal Bluetooth
class BluetoothManager: NSObject, CBCentralManagerDelegate {
    var centralManager: CBCentralManager?
    var peripheral: CBPeripheral?
    let SERVICE_UUID = CBUUID(string: "SERVICE_UUID")
    let CHARACTERISTIC_UUID = CBUUID(string: "CHARACTERISTIC_UUID")
    
    func start() {
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            central.scanForPeripherals(withServices: [SERVICE_UUID], options: nil)
        } else {
            print("Bluetooth not available.")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        self.peripheral = peripheral
        central.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices([SERVICE_UUID])
    }
}

extension BluetoothManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            peripheral.discoverCharacteristics([CHARACTERISTIC_UUID], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            if characteristic.uuid == CHARACTERISTIC_UUID {
                peripheral.readValue(for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let value = characteristic.value {
            // Handle the retrieved value
        }
    }
}
*/

