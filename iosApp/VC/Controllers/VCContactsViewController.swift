//
//  VCContactsViewController.swift
//  VC
//
//  Created/Modified by Thanh N & Nathan A.
//

import UIKit
import ContactsUI
import SwiftUI
import CoreData
import MessageUI
import CoreLocation

var EmergencyContactList = [Contact]()
/// Controller to add and show Emergency Contacts
class VCContactsViewController: UIViewController, UITableViewDataSource, CNContactPickerDelegate, UITableViewDelegate, CLLocationManagerDelegate{
    
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
    
    var coordinates: CLLocationCoordinate2D?
    var locationManager = CLLocationManager()
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
            let phoneNumber = (contact.phoneNumbers[0].value).value(forKey: "digits") as! String
            let managedContext = AppDelegate.sharedAppDelegate.CoreDataStack.managedContext
            let newContact = Contact(context: managedContext)
            newContact.setValue(name, forKey: #keyPath(Contact.contactName))
            newContact.setValue(identifier, forKey: #keyPath(Contact.contactId))
            newContact.setValue(phoneNumber, forKey: #keyPath(Contact.contactPhoneNumber))
            newContact.setValue(contact, forKey: #keyPath(Contact.contactSource))
            EmergencyContactList.insert(newContact, at: 0)
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
                AppDelegate.sharedAppDelegate.CoreDataStack.managedContext.delete(EmergencyContactList[indexPath.row])
                EmergencyContactList.remove(at: indexPath.row)
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
        
        let alert = UIAlertController(title: "Notify \(name ?? "Emergency Contact")",
                                      message: "Click Call or Text to contact \(name ?? "your emergency contact")",
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Call", style: UIAlertAction.Style.default, handler: { _ in
            //Call action
            self.callNumber(phoneNumber: number)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { _ in
            //Cancel action
        }))
        
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true, completion: nil)})
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
    
    func getListOfphoneNumbersInEmergencyContacts() -> Array<String> {
        var phoneNumbers = Array<String>()
        for emergencyContact in EmergencyContactList {
            phoneNumbers.append(emergencyContact.contactPhoneNumber ?? "")
        }
        return phoneNumbers
    }
    
    func getAddressFromGPS(latitude: Double, longitude: Double, completionHandler: @escaping (String?, Error?) -> Void) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                completionHandler(nil, error)
                return
            }
            
            guard let placemark = placemarks?.first else {
                completionHandler(nil, NSError(domain: "com.yourapp", code: -1, userInfo: [NSLocalizedDescriptionKey: "No placemark found"]))
                return
            }
            
            let street = placemark.thoroughfare ?? ""
            let number = placemark.subThoroughfare ?? ""
            let city = placemark.locality ?? ""
            let zipCode = placemark.postalCode ?? ""
            
            let address = "\(number) \(street), \(city) \(zipCode)"
            completionHandler(address, nil)
        }
    }
    
    func textMessageWithTwilio() {
        // Get the location and stop
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        let location = locationManager.location?.coordinate ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        locationManager.stopUpdatingLocation()
        
        // let authToken = ""
        let accountSID = "AC46a348fafe57f4dad8a537d8d7bfce10"
        let authToken = "tempToken"
        let fromNumber = "+18663483216"
        
        //Twilio 160 characters limit per MSG
        let currentLatitude = location.latitude
        let currentLongitude = location.longitude
        
        getAddressFromGPS(latitude: currentLatitude, longitude: currentLongitude) { (address, error) in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                return
            }
            
            let namePlaceHolder = "Vehicle Collision's User"
            var message = "Hi, this is \(namePlaceHolder). I'm in an Emergency, here is my location: "
            
            if let address = address {
                // Concatenate the address to the message
                message += address
                
                let url = URL(string: "https://api.twilio.com/2010-04-01/Accounts/\(accountSID)/Messages")!
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                request.addValue("Basic " + "\(accountSID):\(authToken)".data(using: .utf8)!.base64EncodedString(), forHTTPHeaderField: "Authorization")
                self.getContacts()
                
                for contact in EmergencyContactList {
                    if let toNumber = contact.contactPhoneNumber {
                        let body = "From=\(fromNumber)&To=\(toNumber)&Body=\(message)"
                        print(message)
                        print("Message sent to \(toNumber)! ")
                        
                        request.httpBody = body.data(using: .utf8)
                        
                        let task = URLSession.shared.dataTask(with: request) { data, response, error in
                            if let error = error {
                                print("Error: \(error)")
                            } else if let responseData = data,
                                      let response = response as? HTTPURLResponse,
                                      response.statusCode == 201 {
                                let _ = String(data: responseData, encoding: .utf8) ?? "nil"
                                print("Message sent to \(toNumber)! " + message)
                            } else {
                                let dataString = String(data: data ?? Data(), encoding: .utf8) ?? "nil"
                                let responseString = (response as? HTTPURLResponse)?.statusCode.description ?? "nil"
                                print("Unexpected response: \(responseString), data: \(dataString)")
                            }
                        }
                        task.resume()
                    } else {
                        print("Error: contactPhoneNumber is nil.")
                    }
                }
            } else {
                print("No address found")
            }
        }
    }
    
    func callWithTwilio() {
        let accountSID = "AC46a348fafe57f4dad8a537d8d7bfce10"
        let authToken = "tempToken"
        let fromNumber = "+18663483216"
        let toNumber = "+2674610092"
        
        let url = URL(string: "https://api.twilio.com/2010-04-01/Accounts/\(accountSID)/Calls")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("Basic " + "\(accountSID):\(authToken)".data(using: .utf8)!.base64EncodedString(), forHTTPHeaderField: "Authorization")
        
        let body = "From=\(fromNumber)&To=\(toNumber)&Url=http://demo.twilio.com/docs/voice.xml"
        request.httpBody = body.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
            } else if let responseData = data,
                      let response = response as? HTTPURLResponse,
                      response.statusCode == 201 {
                let _ = String(data: responseData, encoding: .utf8) ?? "nil"
                print("Call initiated to: " + toNumber)
            } else {
                let dataString = String(data: data ?? Data(), encoding: .utf8) ?? "nil"
                let responseString = (response as? HTTPURLResponse)?.statusCode.description ?? "nil"
                print("Unexpected response: \(responseString), data: \(dataString)")
            }
        }
        task.resume()
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
