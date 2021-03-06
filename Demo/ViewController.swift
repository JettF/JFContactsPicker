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
    func contactPicker(_: ContactsPicker, didContactFetchFailed error: NSError) {
        print("Failed with error \(error.description)")
    }
    
    func contactPicker(_: ContactsPicker, didSelectContact contact: Contact) {
        print("Contact \(contact.displayName) has been selected")
    }
    
    func contactPickerDidCancel(_ picker: ContactsPicker) {
        picker.dismiss(animated: true, completion: nil)
        print("User canceled the selection");
    }
    
    func contactPicker(_ picker: ContactsPicker, didSelectMultipleContacts contacts: [Contact]) {
        defer { picker.dismiss(animated: true, completion: nil) }
        guard !contacts.isEmpty else { return }
        print("The following contacts are selected")
        for contact in contacts {
            print("\(contact.displayName)")
        }
    
    }

}
