//
//  VCTabBarControllerTests.swift
//  VCTests
//
//  Created by Thanh Nguyen on 4/20/23.
//

import XCTest
@testable import VC

class VCTabBarControllerTests: XCTestCase {
    
    var tabBarController: VCTabBarController!
    
    override func setUp() {
        super.setUp()
        tabBarController = VCTabBarController()
    }
    
    override func tearDown() {
        tabBarController = nil
        super.tearDown()
    }
    
    func testTabBarHasThreeItems() {
        XCTAssertEqual(tabBarController.tabBar.items?.count, 3, "Tab bar should have three items.")
    }
    
    func testFirstTabBarItemIsStatus() {
        XCTAssertEqual(tabBarController.tabBar.items?[0].title, "Status", "First tab bar item should be 'Status'.")
    }
    
    func testSecondTabBarItemIsContacts() {
        XCTAssertEqual(tabBarController.tabBar.items?[1].title, "Contacts", "Second tab bar item should be 'Contacts'.")
    }
    
    func testThirdTabBarItemIsTesting() {
        XCTAssertEqual(tabBarController.tabBar.items?[2].title, "Testing", "Third tab bar item should be 'Testing'.")
    }
    
    func testTabBarItemSelectedChangesViewController() {
        tabBarController.selectedIndex = 1 // select second tab (Contacts)
        XCTAssertTrue(tabBarController.selectedViewController is UINavigationController, "Selected view controller should be a navigation controller.")
        XCTAssertTrue((tabBarController.selectedViewController as? UINavigationController)?.viewControllers.first is VCContactsViewController, "Selected view controller should be ContactsViewController.")
    }
    
}
