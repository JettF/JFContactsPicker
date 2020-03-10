//
//  Contact.swift
//  JFContactsPicker
//

import UIKit
import Contacts

/// An instance of this class contains information on a single contact in the users phone.
open class Contact {
    
    /*
     *  MARK: - Instance Properties
     */
    
    /// The first name of the contact.
    public let firstName: String
    
    /// The last name of the contact.
    public let lastName: String
    
    /// The name of the company the contact works for.
    public let company: String
    
    /// A thumbnail image to be displayed on a `UITableViewCell`
    public let thumbnailProfileImage: UIImage?
    
    /// The image to be displayed when the contact is selected.
    public let profileImage: UIImage?
    
    /// The contact's birthday.
    public let birthday: Date?
    
    /// The contact's birthday stored as a string.
    public let birthdayString: String?
    
    /// The unique identifier for the contact in the phone database.
    public let contactId: String?
    
    /// An array of the phone numbers associated with the contact.
    public let phoneNumbers: [(phoneNumber: String, phoneLabel: String)]
    
    /// An array of emails associated with the contact,
    public let emails: [(email: String, emailLabel: String )]
    
    private static let dateFormatter: DateFormatter = DateFormatter()
    
    /*
     *  MARK: - Computed Properties
     */
    
    open var displayName: String {
        return firstName + " " + lastName
    }
    
    open var initials: String {
        var initials: String = ""
        
        if let firstNameFirstChar = firstName.first {
            initials.append(firstNameFirstChar)
        }
        
        if let lastNameFirstChar = lastName.first {
            initials.append(lastNameFirstChar)
        }
        
        return initials
    }
    
    /*
     *  MARK: - Object Life Cycle
     */
	
    /// The designated initializer for the class.
    ///
    /// - Parameter contact: A `CNContact` instance which supplies all the property values for this class.
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
            Contact.dateFormatter.dateFormat = GlobalConstants.Strings.birthdayDateFormat
            //Example Date Formats:  Oct 4, Sep 18, Mar 9
            birthdayString = Contact.dateFormatter.string(from: birthday!)
            
        } else {
            birthday = nil
            birthdayString = nil
        }
        
        var numbers: [(String, String)] = []
		for phoneNumber in contact.phoneNumbers {
			let phoneLabel = phoneNumber.label ?? ""
			let phone = phoneNumber.value.stringValue
			
			numbers.append((phone,phoneLabel))
		}
        phoneNumbers = numbers
		
        var emails: [(String, String)] = []
		for emailAddress in contact.emailAddresses {
			let emailLabel = emailAddress.label ?? ""
			let email = emailAddress.value as String
			
			emails.append((email,emailLabel))
		}
        self.emails = emails
        
    }
    
}
