//
//  Contact.swift
//  JFContactsPicker
//

import UIKit
import Contacts

open class Contact {
    
    open let firstName: String
    open let lastName: String
    open let company: String
    open let thumbnailProfileImage: UIImage?
    open let profileImage: UIImage?
    open let birthday: Date?
    open let birthdayString: String?
    open let contactId: String?
    open let phoneNumbers: [(phoneNumber: String, phoneLabel: String)]
    open let emails: [(email: String, emailLabel: String )]
	
    public init (contact: CNContact) {
        firstName = contact.givenName
        lastName = contact.familyName
        company = contact.organizationName
        contactId = contact.identifier
        
        if let thumbnailImageData = contact.thumbnailImageData {
            thumbnailProfileImage = UIImage(data:thumbnailImageData)
            
        } else {
            thumbnailProfileImage = nil
        }
        
        if let imageData = contact.imageData {
            profileImage = UIImage(data:imageData)
        } else {
            profileImage = nil
        }
        
        if let birthdayDate = contact.birthday {
            birthday = Calendar(identifier: Calendar.Identifier.gregorian).date(from: birthdayDate)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = GlobalConstants.Strings.birthdayDateFormat
            //Example Date Formats:  Oct 4, Sep 18, Mar 9
            birthdayString = dateFormatter.string(from: birthday!)
            
        } else {
            birthday = nil
            birthdayString = nil
        }
        
        var numbers: [(String, String)] = []
		for phoneNumber in contact.phoneNumbers {
			guard let phoneLabel = phoneNumber.label else { continue }
			let phone = phoneNumber.value.stringValue
			
			numbers.append((phone,phoneLabel))
		}
        phoneNumbers = numbers
		
        var emails: [(String, String)] = []
		for emailAddress in contact.emailAddresses {
			guard let emailLabel = emailAddress.label else { continue }
			let email = emailAddress.value as String
			
			emails.append((email,emailLabel))
		}
        self.emails = emails
        
    }
	
    open var displayName: String {
        return firstName + " " + lastName
    }
    
    open var initials: String {
        var initials = String()
		
		if let firstNameFirstChar = firstName.characters.first {
			initials.append(firstNameFirstChar)
		}
		
		if let lastNameFirstChar = lastName.characters.first {
			initials.append(lastNameFirstChar)
		}
		
        return initials
    }
    
}
