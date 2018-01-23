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
    open let streets: [(street: String, streetLabel: String )]
    open let states: [(state: String, stateLabel: String )]
    open let postals: [(postal: String, postalLabel: String )]
    open let cities: [(city: String, cityLabel: String )]
    open let countries: [(country: String, countryLabel: String )]
	
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
	    
	var streets: [(String, String)] = []
		for streetAddress in contact.postalAddresses {
			 let streetLabel = streetAddress.label ?? ""
			 let street = streetAddress.value.street as String

			 streets.append((street,streetLabel))
		}
        self.streets = streets
        
        var cities: [(String, String)] = []
        	for cityAddress in contact.postalAddresses {
            		let cityLabel = cityAddress.label ?? ""
            		let city = cityAddress.value.city as String
            
            		cities.append((city,cityLabel))
        }
        self.cities = cities
        
        var states: [(String, String)] = []
        	for stateAddress in contact.postalAddresses {
            		let stateLabel = stateAddress.label ?? ""
            		let state = stateAddress.value.state as String
            
            		states.append((state,stateLabel))
        }
        self.states = states
        
        var postals: [(String, String)] = []
        	for postalAddress in contact.postalAddresses {
            		let postalLabel = postalAddress.label ?? ""
            		let postal = postalAddress.value.postalCode as String
            
            		postals.append((postal,postalLabel))
        }
        self.postals = postals
        
        var countries: [(String, String)] = []
        	for countryAddress in contact.postalAddresses {
            		let countryLabel = countryAddress.label ?? ""
            		let country = countryAddress.value.country as String
            
            		countries.append((country,countryLabel))
        }
        self.countries = countries
        
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
