//
//  VCHomeViewController.swift
//  VC
//
//  Created by Nathan A on 2/1/23.
//

import UIKit
import SwiftUI
import MobileCoreServices

/// Controller to show Home page
final class VCHomeViewController: UIViewController{
    /**
      This method is called after the view controller has loaded its view hierarchy into memory.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Home"
        
        /*
        // Use label as Text Example
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.textColor = .red
        label.center = CGPoint(x: 200, y: 284)
        label.textAlignment = .center
        label.text = "TESTING LABEL"
        
        self.view.addSubview(label)
        */

        // Do any additional setup after loading the view.
    }
}
