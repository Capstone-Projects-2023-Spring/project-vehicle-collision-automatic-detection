//
//  Contact+CoreDataProperties.swift
//  VC
//
//  Created by Nathan A on 3/1/23.
//
//

import Foundation
import CoreData
import ContactsUI


extension Contact {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Contact> {
        return NSFetchRequest<Contact>(entityName: "Contact")
    }

    @NSManaged public var contactName: String?
    @NSManaged public var contactId: String?
    @NSManaged public var contactPhoneNumber: String?
    @NSManaged public var contactSource: CNContact?

}

extension Contact : Identifiable {}
