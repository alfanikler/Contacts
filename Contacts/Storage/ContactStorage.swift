//
//  ContactStorage.swift
//  Contacts
//
//  Created by Alfa on 24.03.2026.
//

import Foundation

protocol ContactStorageProtocol {
    func load() -> [any ContactProtocol]
    func save(contacts: [any ContactProtocol])
}

protocol ContactStoreProtocol {
    func array(forKey defaultName: String) -> [Any]?
    func set(_ value: [Any]?, forKey defaultName: String)
}

final class ContactStore: ContactStoreProtocol {
    private var storage = UserDefaults.standard

    func array(forKey defaultName: String) -> [Any]? {
        storage.array(forKey: defaultName)
    }
    
    func set(_ value: [Any]?, forKey defaultName: String) {
        storage.set(value, forKey: defaultName)
    }
}

// Без NSObject падают тесты!
final class ContactStorage: NSObject {
    private let store: ContactStoreProtocol
    private let key = "contacts"
    
    private enum ContactKey: String {
        case title, phone
    }
    
    init(store: ContactStoreProtocol = ContactStore()) {
        self.store = store
    }
}

extension ContactStorage: ContactStorageProtocol {
    func load() -> [any ContactProtocol] {
        var resultContacts = [any ContactProtocol]()
        let contactsFromStorage = store.array(forKey: key) as? [[String: String]] ?? []
        
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
    
    func save(contacts: [any ContactProtocol]) {
        var arrayForStorage = [[String: String]]()
        
        contacts.forEach { contact in
            var newElementForStorage = [String:String]()
            
            newElementForStorage[ContactKey.title.rawValue] = contact.title
            newElementForStorage[ContactKey.phone.rawValue] = contact.phone
            arrayForStorage.append(newElementForStorage)
        }
        
        store.set(arrayForStorage, forKey: key)
    }
}
