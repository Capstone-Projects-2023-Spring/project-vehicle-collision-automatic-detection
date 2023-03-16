//
//  BluetoothManager.swift
//  VC
//
//  Created by Thanh Nguyen on 3/11/23.
//

import CoreBluetooth
import UIKit

// Bluetooth LE
protocol BluetoothManagerDelegate: AnyObject {
    func didConnectPeripheral()
    func didDisconnectPeripheral()
}

class BluetoothManager: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    weak var delegate: BluetoothManagerDelegate?
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            // Bluetooth is ready to use
            central.scanForPeripherals(withServices: nil, options: nil)
        } else {
            // Bluetooth is not available
        }
    }
    
    // Scan for nearby peripheral devices using the CBCentralManager's scanForPeripherals.
    func startScanning() {
        centralManager.scanForPeripherals(withServices: [BLEServiceUUID], options: nil)
    }
    
    let BLEServiceUUID = CBUUID(string: "6FB1FDA5-C272-43A5-9C1B-A38E2BBDDF2F")
    
    // Connect to the desired peripheral device using the CBCentralManager.
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name == "Adafruit Bluefruit LE" {
            centralManager.stopScan()
            self.peripheral = peripheral
            self.peripheral.delegate = self
            centralManager.connect(peripheral, options: nil)
        }
    }
    
    // When connect to the Peripheral
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        delegate?.didConnectPeripheral()
    }
    
    // When disconnect from the Peripheral
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        delegate?.didDisconnectPeripheral()
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
