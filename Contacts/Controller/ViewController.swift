//
//  ViewController.swift
//  Contacts
//
//  Created by Alfa on 23.03.2026.
//

import UIKit

final class ViewController: UIViewController {
    
    private var storage: ContactStorageProtocol!
    
    private var contacts: [ContactProtocol] = [] {
        didSet {
            contacts.sort { $0.title < $1.title }
            storage.save(contacts: contacts)
        }
    }
    
    @IBOutlet private weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        storage = ContactStorage()
        loadContacts()
    }
    
    @IBAction private func showNewContactAlert() {
        let alertController = UIAlertController(
            title: "Create new contact",
            message: "Type name and phone",
            preferredStyle: .alert
        )
        
        alertController.addTextField { textField in
            textField.placeholder = "Name"
        }
        
        alertController.addTextField { textField in
            textField.placeholder = "Phone"
        }
        
        let createButton = UIAlertAction(title: "Create", style: .default) { _ in
            guard
                let contactName = alertController.textFields?[0].text,
                let contactPhone = alertController.textFields?[1].text
            else {
                return
            }
            
            let contact = Contact(title: contactName, phone: contactPhone)
            
            self.contacts.append(contact)
            self.tableView.reloadData()
        }
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(cancelButton)
        alertController.addAction(createButton)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func loadContacts() {
        contacts = storage.load()
    }
}

// MARK: UITableViewDataSource

extension ViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        
        if let reuseCell = tableView.dequeueReusableCell(withIdentifier: "myCell") {
            cell = reuseCell
        } else {
            cell = UITableViewCell(style: .default, reuseIdentifier: "myCell")
        }
            
        configure(cell: &cell, for: indexPath)
        
        return cell
    }
    
    private func configure(cell: inout UITableViewCell, for indexPath: IndexPath) {
        var configuration = cell.defaultContentConfiguration()
        
        configuration.text = contacts[indexPath.row].title
        configuration.secondaryText = contacts[indexPath.row].phone
        cell.contentConfiguration = configuration
    }
}

// MARK: UITableViewDelegate

extension ViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let actionDelete = UIContextualAction(style: .destructive, title: "Delete") { _,_,_ in
            self.contacts.remove(at: indexPath.row)
            tableView.reloadData()
        }
        
        let actions = UISwipeActionsConfiguration(actions: [actionDelete])
        
        return actions
    }
}
