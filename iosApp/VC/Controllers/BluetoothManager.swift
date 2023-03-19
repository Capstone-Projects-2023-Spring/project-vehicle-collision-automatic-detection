//
//  BluetoothManager.swift
//  VC
//
//  Created by Thanh Nguyen on 3/11/23.
//

import CoreBluetooth
import UIKit
import CallKit

// Bluetooth LE
protocol BluetoothManagerDelegate: AnyObject {
    func didConnectPeripheral()
    func didDisconnectPeripheral()
}

class BluetoothManager: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate, CXCallObserverDelegate {
    weak var delegate: BluetoothManagerDelegate?
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral!
    let BLEServiceUUID = CBUUID(string: "0000181A-0000-1000-8000-00805F9B34FB")
    var callObserver = CXCallObserver()
    
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
        callObserver.setDelegate(self, queue: nil)
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
    
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        if call.hasConnected {
            print("Call connected")
        } else if call.hasEnded {
            print("Call ended")
        }
    }
    
    // Read/Write/Handle the data
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let value = characteristic.value else { return }
        let stringValue = String(data: value, encoding: .utf8)
        if stringValue == "signal" { // replace "signal" with actual signal that Adafruit sends
            let callController = CXCallController()
            let callHandle = CXHandle(type: .phoneNumber, value: "1234567890")
            let startCallAction = CXStartCallAction(call: UUID(), handle: callHandle)
            callController.requestTransaction(with: startCallAction, completion: { error in
                if let error = error {
                    print("Error starting call: \(error.localizedDescription)")
                } else {
                    print("Call initiated")
                }
            })
        }
    }
    
    /*
     func writeToCharacteristic(data: Data) {
     guard let characteristic = self.characteristic else { return }
     peripheral.writeValue(data, for: characteristic, type: .withResponse)
     }
     */
    
}
