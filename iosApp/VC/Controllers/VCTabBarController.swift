//
//  ViewController.swift
//  VC
//
//  Created by Nathan A on 2/1/23.
//

import UIKit
import SwiftUI
import MobileCoreServices

/// Controller to house tabs and root controllers
final class VCTabBarController
: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTabs()
    }
    
    private func setUpTabs() {
        let HomeViewController = VCHomeViewController()
        let ContactsViewController = VCContactsViewController()
        let SettingViewController = VCSettingViewController()
        
        HomeViewController.navigationItem.largeTitleDisplayMode = .automatic
        ContactsViewController.navigationItem.largeTitleDisplayMode = .automatic
        SettingViewController.navigationItem.largeTitleDisplayMode = .automatic
                
        let nav1 = UINavigationController(rootViewController: HomeViewController)
        let nav2 = UINavigationController(rootViewController: ContactsViewController)
        let nav3 = UINavigationController(rootViewController: SettingViewController)
        
        nav1.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 1)
        nav2.tabBarItem = UITabBarItem(title: "Contacts", image: UIImage(systemName: "person.circle.fill"), tag: 2)
        nav3.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gear"), tag: 3)
        
        for nav in [nav1, nav2, nav3] {
            nav.navigationBar.prefersLargeTitles = true
        }
        
        setViewControllers(
            [nav1, nav2, nav3],
            animated: true
        )
    }

}

