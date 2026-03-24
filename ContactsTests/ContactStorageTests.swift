//
//  ContactsTests.swift
//  ContactsTests
//
//  Created by Alfa on 23.03.2026.
//

import XCTest
@testable import Contacts

final class MockContactStore: ContactStoreProtocol {
    typealias SetMethodCallsItem = (array: [[String: String]], defaultName: String)
    
    var arrayMethodCalls = [String]()
    var setMethodCalls = [SetMethodCallsItem]()
    
    func array(forKey defaultName: String) -> [Any]? {
        arrayMethodCalls.append(defaultName)
        return []
    }

    func set(_ array: [Any]?, forKey defaultName: String) {
        let call = (array: array as! [[String: String]], defaultName: defaultName)
        setMethodCalls.append(call)
    }
}

@MainActor
final class ContactsStorageTests: XCTestCase {
    func testSaveAndGetContacts() throws {
        let mockContactStore = MockContactStore()
        let contactStorage = ContactStorage(store: mockContactStore)

        let testContact1 = Contact(title: "Test1", phone: "Test1")
        let testContact2 = Contact(title: "Test2", phone: "Test2")
        
        var contacts = [Contact]()
        var calls = [MockContactStore.SetMethodCallsItem]()
        
        XCTAssertEqual(calls.count, 0)
        
        // Добавляем первый контакт
        contacts.append(testContact1)
        contactStorage.save(contacts: contacts)
        calls = mockContactStore.setMethodCalls
        
        XCTAssertEqual(calls.count, 1)
        XCTAssertEqual(calls.last?.array[0], ["title": testContact1.title, "phone": testContact1.phone])
        XCTAssertEqual(calls.last?.defaultName, "contacts")
        
        // Добавляем второй контакт
        contacts.append(testContact2)
        contactStorage.save(contacts: contacts)
        calls = mockContactStore.setMethodCalls
        
        XCTAssertEqual(calls.count, 2)
        XCTAssertEqual(calls.last?.array[0], ["title": testContact1.title, "phone": testContact1.phone])
        XCTAssertEqual(calls.last?.array[1], ["title": testContact2.title, "phone": testContact2.phone])
        XCTAssertEqual(calls.last?.defaultName, "contacts")
        
        // Удаляем контакты
        contacts.removeAll()
        contactStorage.save(contacts: contacts)
        calls = mockContactStore.setMethodCalls
        
        XCTAssertEqual(calls.count, 3)
        XCTAssertEqual(calls.last?.array, [])
        XCTAssertEqual(calls.last?.defaultName, "contacts")
        
        // Проверяем получение контактов
        XCTAssertEqual(mockContactStore.arrayMethodCalls.count, 0)

        _ = contactStorage.load()
        
        XCTAssertEqual(mockContactStore.arrayMethodCalls.count, 1)
        
        _ = contactStorage.load()
        
        XCTAssertEqual(mockContactStore.arrayMethodCalls.count, 2)
    }
}
