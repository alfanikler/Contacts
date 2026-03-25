//
//  ContactsTests.swift
//  ContactsTests
//
//  Created by Alfa on 23.03.2026.
//

import XCTest
@testable import Contacts

final class MockContactStore: ContactStoreProtocol {
    typealias SetMethodArgs = (array: [[String: String]], defaultName: String)
    
    var callsToArrayMethod = [String]()
    var callsToSetMethod = [SetMethodArgs]()
    
    func array(forKey defaultName: String) -> [Any]? {
        callsToArrayMethod.append(defaultName)
        return []
    }

    func set(_ array: [Any]?, forKey defaultName: String) {
        let call = (array: array, defaultName: defaultName) as! SetMethodArgs
        callsToSetMethod.append(call)
    }
}

final class ContactsStorageTests: XCTestCase {
    func testSaveAndGetContacts() throws {
        let mockContactStore = MockContactStore()
        let contactStorage = ContactStorage(store: mockContactStore)

        let testContact1 = Contact(title: "Test1", phone: "Test1")
        let testContact2 = Contact(title: "Test2", phone: "Test2")
        
        var contacts = [Contact]()
        var calls = [MockContactStore.SetMethodArgs]()
        
        XCTAssertEqual(calls.count, 0)
        
        // Добавляем первый контакт
        contacts.append(testContact1)
        contactStorage.save(contacts: contacts)
        calls = mockContactStore.callsToSetMethod
        
        XCTAssertEqual(calls.count, 1)
        XCTAssertEqual(calls.last?.array[0], ["title": testContact1.title, "phone": testContact1.phone])
        XCTAssertEqual(calls.last?.defaultName, "contacts")
        
        // Добавляем второй контакт
        contacts.append(testContact2)
        contactStorage.save(contacts: contacts)
        calls = mockContactStore.callsToSetMethod
        
        XCTAssertEqual(calls.count, 2)
        XCTAssertEqual(calls.last?.array[0], ["title": testContact1.title, "phone": testContact1.phone])
        XCTAssertEqual(calls.last?.array[1], ["title": testContact2.title, "phone": testContact2.phone])
        XCTAssertEqual(calls.last?.defaultName, "contacts")
        
        // Удаляем контакты
        contacts.removeAll()
        contactStorage.save(contacts: contacts)
        calls = mockContactStore.callsToSetMethod
        
        XCTAssertEqual(calls.count, 3)
        XCTAssertEqual(calls.last?.array, [])
        XCTAssertEqual(calls.last?.defaultName, "contacts")
        
        // Проверяем получение контактов
        XCTAssertEqual(mockContactStore.callsToArrayMethod.count, 0)

        _ = contactStorage.load()
        
        XCTAssertEqual(mockContactStore.callsToArrayMethod.count, 1)
        
        _ = contactStorage.load()
        
        XCTAssertEqual(mockContactStore.callsToArrayMethod.count, 2)
    }
}
