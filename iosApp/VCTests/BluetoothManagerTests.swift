//
//  BluetoothManagerTests.swift
//  VCTests
//
//  Created by Thanh Nguyen on 4/20/23.
//

import XCTest
@testable import VC

class BluetoothManagerTests: XCTestCase {
    var bluetoothManager: BluetoothManager!
    
    override func setUp() {
        super.setUp()
        bluetoothManager = BluetoothManager.shared
    }
    
    override func tearDown() {
        bluetoothManager = nil
        super.tearDown()
    }
    
    func testBluetoothManagerDelegateMethods() {
        let mockDelegate = MockBluetoothManagerDelegate()
        bluetoothManager.delegate = mockDelegate
        
        // Test didConnectPeripheral()
        bluetoothManager.centralManager(bluetoothManager.centralManager, didConnect: bluetoothManager.peripheral)
        XCTAssertTrue(mockDelegate.didConnectPeripheralCalled)
        
        // Test didDisconnectPeripheral()
        bluetoothManager.centralManager(bluetoothManager.centralManager, didDisconnectPeripheral: bluetoothManager.peripheral, error: nil)
        XCTAssertTrue(mockDelegate.didDisconnectPeripheralCalled)
        
        // Test didReceiveData(_ data: Data)
        let testData = Data([0x01, 0x02, 0x03])
        bluetoothManager.peripheral(bluetoothManager.peripheral, didUpdateValueFor: bluetoothManager.rxCharacteristic!, error: nil)
        XCTAssertEqual(mockDelegate.receivedData, testData)
    }
    
    func testBluetoothManagerConnect() {
        bluetoothManager.centralManagerDidUpdateState(bluetoothManager.centralManager)
        XCTAssertEqual(bluetoothManager.centralManager.state, .poweredOn)
        
        bluetoothManager.startScanning()
        XCTAssertTrue(bluetoothManager.centralManager.isScanning)
    }
}

class MockBluetoothManagerDelegate: BluetoothManagerDelegate {
    var didConnectPeripheralCalled = false
    var didDisconnectPeripheralCalled = false
    var receivedData: Data?
    func didConnectPeripheral() {
        didConnectPeripheralCalled = true
    }
    
    func didDisconnectPeripheral() {
        didDisconnectPeripheralCalled = true
    }
    
    func didReceiveData(_ data: Data) {
        receivedData = data
    }
}
