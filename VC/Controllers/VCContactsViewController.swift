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

struct Contact: Identifiable {
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
    
    var EmergencyContantList = [Contact]()
    
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
    
    @objc func didTapAdd() {        let viewController = CNContactPickerViewController()
        viewController.delegate = self
        present(viewController, animated: true)
    }
    
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        let name = contact.givenName + " " + contact.familyName
        let identifier = contact.identifier
        let person = Contact(name: name,
                           id: identifier,
                           source: contact
        )
        EmergencyContantList.append(person)
        table.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        EmergencyContantList.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt  indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            EmergencyContantList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = EmergencyContantList[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let contact = EmergencyContantList[indexPath.row].source
        let viewController = CNContactViewController(for: contact)
        present(UINavigationController(rootViewController: viewController), animated: true)
    }
}
