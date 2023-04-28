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
    
    func test_SetUpTabs_SetsUpThreeTabs() {
        // Given
        let expectedCount = 3
        
        // When
        tabBarController.setUpTabs()
        
        // Then
        XCTAssertEqual(tabBarController.viewControllers?.count, expectedCount, "The number of view controllers should be 3.")
    }
    
    func test_SetUpTabs_SetsUpCorrectTabBarItems() {
        // Given
        let expectedTitles = ["Status", "Contacts", "Testing"]
        let expectedTags = [1, 2, 3]
        
        // When
        tabBarController.setUpTabs()
        
        // Then
        guard let viewControllers = tabBarController.viewControllers else {
            XCTFail("viewControllers should not be nil.")
            return
        }
        
        for i in 0..<viewControllers.count {
            let vc = viewControllers[i]
            XCTAssertEqual(vc.tabBarItem.title, expectedTitles[i], "The title of the tab bar item should be correct.")
            XCTAssertEqual(vc.tabBarItem.tag, expectedTags[i], "The tag of the tab bar item should be correct.")
        }
    }
    
    func test_SetUpTabs_SetsUpLargeTitles() {
        // When
        tabBarController.setUpTabs()
        
        // Then
        guard let viewControllers = tabBarController.viewControllers else {
            XCTFail("viewControllers should not be nil.")
            return
        }
        
        for vc in viewControllers {
            if let navVC = vc as? UINavigationController {
                XCTAssertTrue(navVC.navigationBar.prefersLargeTitles, "The navigation bar should prefer large titles.")
                XCTAssertEqual(navVC.navigationItem.largeTitleDisplayMode, .automatic, "The large title display mode should be automatic.")
            }
        }
    }
}
