//
//  VCEmergencyContactViewController.swift
//  VC
//
//  Created by Nathan A on 2/1/23.
//

import UIKit
import ContactsUI
import SwiftUI
import CoreData
import MessageUI
import MapKit
import CoreLocation


/// Controller to add and show Emergency Contacts
class VCContactsViewController: UIViewController, UITableViewDataSource, CNContactPickerDelegate, UITableViewDelegate, CLLocationManagerDelegate, MFMessageComposeViewControllerDelegate {
    
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
    
    var EmergencyContactList = [Contact]()
    var coordinates: CLLocationCoordinate2D?
    let locationManager = CLLocationManager()
    
    
    /**
     This method is called after the view controller has loaded its view hierarchy into memory.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestAlwaysAuthorization()
        
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.delegate = self
                self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                self.locationManager.startUpdatingLocation()
            }
        }
        
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
        self.getContacts()
    }
    
    /// Opens the default contact application once user clicks on the add button
    @objc func didTapAdd() {
        let viewController = CNContactPickerViewController()
        viewController.delegate = self
        present(viewController, animated: true)
        
    }
    
    @IBAction func sendLocation(_ sender: UIButton) {
        locationManager.requestLocation()
    }
    
    /**
     Checks if a contact has been selected by the user
     
     - Parameters:
        - CNContactPickerViewController: The default iOS contact application
        -  Contact: A specific contact from the contact app
     
     */
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        if EmergencyContactList.contains(where: {$0.contactId == contact.identifier}) {
            duplicatedContactAlert()
            
        } else  {
            let name = contact.givenName + " " + contact.familyName
            let identifier = contact.identifier
            let managedContext = AppDelegate.sharedAppDelegate.CoreDataStack.managedContext
            let newContact = Contact(context: managedContext)
            newContact.setValue(name, forKey: #keyPath(Contact.contactName))
            newContact.setValue(identifier, forKey: #keyPath(Contact.contactId))
            newContact.setValue(contact, forKey: #keyPath(Contact.contactSource))
            self.EmergencyContactList.insert(newContact, at: 0)
            AppDelegate.sharedAppDelegate.CoreDataStack.saveContext() // Save changes in CoreData
            DispatchQueue.main.async {
                self.table.reloadData()
            }
        }
        
    }
    
    /**
     Checks if newly selected contact already exists in the Emergency Contact list and handles duplicated contacts accordingly.
     
     - Parameters:
     -
     - Returns: Alerts the user
     
     */
    func duplicatedContactAlert() {
        let alert = UIAlertController(title: "Duplicated Contact", message: "The contact you are trying to add already exists in the Emergency Contacts list",
                                      preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { _ in
            //Ok action
            return
        }))
        
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true, completion: nil)})
    }
    
    /**
     Checks if row can be editted
     
     - Parameters:
     - UITableView: The table view
     - Section: The section of the emergency contacts
     
     - Returns: The count of Emergency contacts added
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        EmergencyContactList.count
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
            let alert = UIAlertController(title: "Delete Contact?", message: "You will no longer be able to automatically notify this contact once deleted from the Emergency Contacts list", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { _ in
                //Cancel Action
                
                
            }))
            alert.addAction(UIAlertAction(title: "Delete",
                                          style: UIAlertAction.Style.destructive,
                                          handler: {(_: UIAlertAction!) in
                //Delete action
                // Remove the contact from the CoreData
                AppDelegate.sharedAppDelegate.CoreDataStack.managedContext.delete(self.EmergencyContactList[indexPath.row])
                self.EmergencyContactList.remove(at: indexPath.row)
                // Save Changes
                AppDelegate.sharedAppDelegate.CoreDataStack.saveContext()
                // Remove row from TableView
                tableView.deleteRows(at: [indexPath], with: .fade)
                
                
            }))
            DispatchQueue.main.async(execute: {
                self.present(alert, animated: true, completion: nil)})
            
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
        cell.textLabel?.text = EmergencyContactList[indexPath.row].contactName
        return cell
    }
    
    /**
     Presents option to call or text contact when selected from the Emergency Contacts list
     
     - Parameters:
        - UITableView: The table view
        - IndexPath: The indexPath of the row
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let contact = EmergencyContactList[indexPath.row].contactSource else { return }
        _ = CNContactViewController(for: contact)
        let number = (contact.phoneNumbers[0].value ).value(forKey: "digits") as! String
        let name = EmergencyContactList[indexPath.row].contactName
        
        
        let alert = UIAlertController(title: "Notify \(name ?? "Emergency Contact")", message: "Click Call or Text to contact \(name ?? "your emergency contact")",
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Call", style: UIAlertAction.Style.default, handler: { _ in
            //Call action
            self.callNumber(phoneNumber: number)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Text", style: UIAlertAction.Style.default, handler: { _ in
            //Message action
            self.textNumber(phoneNumber: number)
            
        }))
        
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { _ in
            //Cancel action
        }))
        
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true, completion: nil)})
    }
    
    /**
    Closes the message view controller when done
     
     - Parameters:
        - controller: The phone number of the recipient
        - result: The result

     */
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        // Check the result or perform other tasks.

        // Dismiss the message compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }
    
    /**
     Gets the location of the device
     
     - Parameters:
        - CLLocationManager: The location manager used to retrieve the location of the device
        - CLLocation: A list of locations of type CLLocation
     
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        coordinates = locValue
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
    /**
     Handles failure to get a user's location
     
     - Parameters:
        - CLLocationManager: The location manager used to retrieve the location of the device
        - Error: Error preventing location retrieval
     
     */
    func locationManager( _ manager: CLLocationManager, didFailWithError error: Error) {
        // Handle failure to get a user’s location
        print(error.localizedDescription)
    }
    
    /**
    Makes a phone call when clicked
     
     - Parameters:
        - phoneNumber: The phone number of the recipient
     
     */
    private func callNumber(phoneNumber: String) {
        guard let url = URL(string: "telprompt://\(phoneNumber)"),
              UIApplication.shared.canOpenURL(url)
        else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    /**
    Texts when clicked
     
     - Parameters:
        - phoneNumber: The phone number of the recipient
     
     */
    private func textNumber(phoneNumber: String) {
        if MFMessageComposeViewController.canSendText() {
            let composeVC = MFMessageComposeViewController()
            composeVC.messageComposeDelegate = self
            
            let defaultEmergencyMsg = "Emergency! I was just in a car accident. As one of my emergency contacts, I wanted to keep you updated. "
            
            let location = "Here is my current location. https://www.google.com/maps/place/\(coordinates?.latitude ?? 0),\(coordinates?.longitude ?? 0)"
            
            composeVC.recipients = [phoneNumber]
            composeVC.body = defaultEmergencyMsg + location
            locationManager.stopUpdatingLocation()
            
            self.present(composeVC, animated: true, completion: nil)
        }
    }
    
    /**
     Fetches data. This method gets the list of Contacts from the CoreData using NSFetchRequest. Called everytime we open the app
     
     - Parameters:
     
     - Returns: Contacts Data from CoreData
     */
    private func getContacts() {
        let contactFetch: NSFetchRequest<Contact> = Contact.fetchRequest()
        let sortByName = NSSortDescriptor(key: #keyPath(Contact.contactName), ascending: false)
        contactFetch.sortDescriptors = [sortByName]
        do {
            let managedContext = AppDelegate.sharedAppDelegate.CoreDataStack.managedContext
            let results = try managedContext.fetch(contactFetch)
            EmergencyContactList = results
        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
        }
    }
}
