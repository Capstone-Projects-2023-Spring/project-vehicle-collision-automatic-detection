//
//  BluetoothManager.swift
//  VC
//
//  Created/Modified by Thanh N & Nathan A.
//

import CoreBluetooth
import UIKit
import CallKit

// Bluetooth LE
protocol BluetoothManagerDelegate: AnyObject {
    func didConnectPeripheral()
    func didDisconnectPeripheral()
    func didReceiveData(_ data: Data)
}

class BluetoothManager: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    weak var delegate: BluetoothManagerDelegate?
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral!
    let BLEServiceUUID = CBUUID(string: "00110011-4455-6677-8899-aabbccddeeff")
    internal var rxCharacteristic: CBCharacteristic?
    
    // Singleton instance
    static let shared = BluetoothManager()
    
    // Private initializer
    private override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // Required initializer
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        self.peripheral = peripheral
        peripheral.delegate = self
        peripheral.discoverServices([CBUUID(string: "00110011-4455-6677-8899-aabbccddeeff")])
        delegate?.didConnectPeripheral()
    }
    
    // When disconnect from the Peripheral
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        delegate?.didDisconnectPeripheral()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {
            return
        }
        for service in services {
            peripheral.discoverCharacteristics([CBUUID(string: "00112233-4455-6677-8899-abbccddeefff")], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            return
        }
        for characteristic in characteristics {
            if characteristic.uuid == CBUUID(string: "00112233-4455-6677-8899-abbccddeefff") {
                self.rxCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    // Read/Write/Handle the data
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard characteristic.uuid == CBUUID(string: "00112233-4455-6677-8899-abbccddeefff") else {
            return
        }
        if let value = characteristic.value {
            delegate?.didReceiveData(value)
        }
    }
}
