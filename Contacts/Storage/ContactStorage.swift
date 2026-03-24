//
//  ContactStorage.swift
//  Contacts
//
//  Created by Alfa on 24.03.2026.
//

import Foundation

protocol ContactStorageProtocol {
    func load() -> [ContactProtocol]
    func save(contacts: [ContactProtocol])
}

class ContactStorage: ContactStorageProtocol {
    
    private var storage = UserDefaults.standard
    private let storageKey = "contacts"
    
    private enum ContactKey: String {
        case title, phone
    }
    
    func load() -> [ContactProtocol] {
        var resultContacts = [ContactProtocol]()
        let contactsFromStorage = storage.array(forKey: storageKey) as? [[String: String]] ?? []
        
        contactsFromStorage.forEach { contact in
            guard
                let title = contact[ContactKey.title.rawValue],
                let phone = contact[ContactKey.phone.rawValue]
            else {
                return
            }
            
            resultContacts.append(Contact(title: title, phone: phone))
        }
        
        return resultContacts
    }
    
    func save(contacts: [ContactProtocol]) {
        var arrayForStorage = [[String: String]]()
        
        contacts.forEach { contact in
            var newElementForStorage = [String:String]()
            
            newElementForStorage[ContactKey.title.rawValue] = contact.title
            newElementForStorage[ContactKey.phone.rawValue] = contact.phone
            arrayForStorage.append(newElementForStorage)
        }
        
        storage.set(arrayForStorage, forKey: storageKey)
    }
}
