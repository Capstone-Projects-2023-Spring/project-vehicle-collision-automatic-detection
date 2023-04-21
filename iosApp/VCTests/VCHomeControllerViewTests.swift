//
//  VCHomeControllerViewTests.swift
//  VCTests
//
//  Created/modidified Nathan Adiam & Thanh Nuygen 
//

import XCTest
@testable import VC

class VCHomeViewControllerTests: XCTestCase {
    
    var sut: VCHomeViewController!
    
    override func setUp() {
        super.setUp()
        sut = VCHomeViewController()
        _ = sut.view
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testPeripheralStatusLabelIsNotNil() {
        XCTAssertNotNil(sut.peripheralStatusLabel)
    }
    
    func testPeripheralStatusLabelTextIsDisconnected() {
        XCTAssertEqual(sut.peripheralStatusLabel.text, "Device disconnected")
    }
    
    func testPeripheralStatusLabelTextColorIsRed() {
        XCTAssertEqual(sut.peripheralStatusLabel.textColor, UIColor.red)
    }
    
    func testDidConnectPeripheral() {
        sut.didConnectPeripheral()
        XCTAssertEqual(sut.peripheralStatusLabel.text, "Device connected")
        XCTAssertEqual(sut.peripheralStatusLabel.textColor, UIColor.green)
    }
    
    func testDidDisconnectPeripheral() {
        sut.didDisconnectPeripheral()
        XCTAssertEqual(sut.peripheralStatusLabel.text, "Device disconnected")
        XCTAssertEqual(sut.peripheralStatusLabel.textColor, UIColor.red)
    }
    
    func testDidReceiveData() {
        let data = "F".data(using: .utf8)!
        sut.didReceiveData(data)
        XCTAssertEqual(sut.dataFromAdafruit.text, "F")
        XCTAssertEqual(sut.dataFromAdafruit.textColor, UIColor.blue)
    }
}

