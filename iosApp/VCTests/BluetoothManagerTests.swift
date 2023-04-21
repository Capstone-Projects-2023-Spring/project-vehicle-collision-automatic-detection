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
