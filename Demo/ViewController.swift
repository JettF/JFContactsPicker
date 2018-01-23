//
//  ViewController.swift
//  JFContactsPicker
//

import UIKit

class ViewController: UIViewController, ContactsPickerDelegate {
  
  @IBAction func onTouchShowMeContactsButton(_ sender: AnyObject) {
    let contactPickerScene = ContactsPicker(delegate: self, multiSelection: true, subtitleCellType: SubtitleCellValue.email)
    let navigationController = UINavigationController(rootViewController: contactPickerScene)
    self.present(navigationController, animated: true, completion: nil)
    
  }
    
//MARK: EPContactsPicker delegates
    func contactPicker(_: ContactsPicker, didContactFetchFailed error: NSError)
    {
        print("Failed with error \(error.description)")
    }
    
    func contactPicker(_: ContactsPicker, didSelectContact contact: Contact)
    {
        print("Contact \(contact.displayName) has been selected")
        //Example: extract first postal address
        print("Street: \(contact.streets[0].street)")
        print("State: \(contact.states[0].state)")
        print("PostalCode: \(contact.postals[0].postal)")
        print("City: \(contact.cities[0].city)")
        print("Country: \(contact.countries[0].country)")
    }
    
    func contactPicker(_: ContactsPicker, didCancel error: NSError)
    {
        print("User canceled the selection");
    }
    
    func contactPicker(_: ContactsPicker, didSelectMultipleContacts contacts: [Contact]) {
        print("The following contacts are selected")
        for contact in contacts {
            print("\(contact.displayName)")
        }
    }

}
