//
//  VCEmergencyContactViewController.swift
//  VC
//
//  Created by Nathan A on 2/1/23.
//

import UIKit
import Contacts
import ContactsUI
import SwiftUI

struct Person {
    let name: String
    let id: String
    let source: CNContact
}
/// Controller to show and add Emergency Contacts
class VCContactsViewController: UIViewController, UITableViewDataSource, CNContactPickerDelegate, UITableViewDelegate {
    
    private let table: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self,
                       forCellReuseIdentifier: "cell")
        return table
    }()
    
    var models = [Person]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(table)
        table.frame = view.bounds
        table.dataSource = self
        table.delegate = self
        view.backgroundColor = .systemBackground
        title = "Emergency Contacts"
        navigationItem.rightBarButtonItem = UIBarButtonItem (
            barButtonSystemItem: .add,
            target: self,
            action: #selector(didTapAdd))
        
    }
    @objc func didTapAdd() {
        let viewController = CNContactPickerViewController()
        viewController.delegate = self
        present(viewController, animated: true)
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        let name = contact.givenName + " " + contact.familyName
        let identifier = contact.identifier
        let model = Person(name: name,
                           id: identifier,
                           source: contact
        )
        models.append(model)
        table.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = models[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let contact = models[indexPath.row].source
        let viewController = CNContactViewController(for: contact)
        let vc2 = UINavigationController(rootViewController: viewController)
        present(vc2, animated: true)
        
    }
}
