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
import CoreData

struct Contact: Identifiable {
    let name: String
    let id: String
    let source: CNContact
}
/// Controller to add and show Emergency Contacts
class VCContactsViewController: UIViewController, UITableViewDataSource, CNContactPickerDelegate, UITableViewDelegate {
    
    var contactsContainer: NSPersistentContainer!
    /**
         Creates a table to store the emergency contacts

        - Returns: The table made
         */
    private let table: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self,
                       forCellReuseIdentifier: "cell")
        return table
    }()
    
    var EmergencyContantList = [Contact]()
    /**
      This method is called after the view controller has loaded its view hierarchy into memory.
     */
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
        guard contactsContainer != nil else {
            fatalError("This view needs a persistent container.")
        }
    }
    
    /// Opens the default contact application once user clicks on the add button
    @objc func didTapAdd() {
        let viewController = CNContactPickerViewController()
        viewController.delegate = self
        present(viewController, animated: true)
    }
    
    /**
         Checks if a contact has been selected by the user

         - Parameters:
            - CNContactPickerViewController: The default iOS contact application
            - Contact: A specific contact from the contact app
     
         */
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
    
    /**
         Checks if row can be editted

         - Parameters:
            - UITableView: The table view
            - Section: The section of the emergency contacts
     
        - Returns: The count of Emergency contacts added
         */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        EmergencyContantList.count
    }
    
    /**
         Checks if row can be edited

         - Parameters:
            - UITableView: The table view
            - IndexPath: The row at index path
     
        - Returns: If it's possible to edit a specific row
         */
    func tableView(_ tableView: UITableView, canEditRowAt  indexPath: IndexPath) -> Bool {
        return true
    }
    
    /**
         Allows to slide row to delete Emergency contacts

         - Parameters:
            - UITableView: The table view
            - UITableViewCell.EditingStyle: The editing style
            - IndexPath: The row at index path
         */
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            EmergencyContantList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            
        }
    }
    
    /**
         Finds the cell at a given row

         - Parameters:
            - UITableView: The table view
            - IndexPath: The indexPath of the row
            - UITableViewCell: The UITableViewCell

         - Returns: A cell for a given row
         */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = EmergencyContantList[indexPath.row].name
        return cell
    }
    
    /**
         Presents the selected contacts

         - Parameters:
            - UITableView: The table view
            - IndexPath: The indexPath of the row
         */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let contact = EmergencyContantList[indexPath.row].source
        let viewController = CNContactViewController(for: contact)
        present(UINavigationController(rootViewController: viewController), animated: true)
    }
}
