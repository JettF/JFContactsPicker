//
//  Constants.swift
//  JFContactsPicker
//

import UIKit

//Declare all the static constants here
struct GlobalConstants {
    
//MARK: String Constants
    struct Strings {
        static let birthdayDateFormat = "MMM d"
        static let contactsTitle = "Contacts"
        static let phoneNumberNotAvaialable = "No phone numbers available"
        static let emailNotAvaialable = "No emails available"
        static let bundleIdentifier = "JFContactsPicker"
        static let cellNibIdentifier = "JFContactCell"
    }

//MARK: Color Constants
    struct Colors {
        static let emerald = UIColor(red: (46/255), green: (204/255), blue: (113/255), alpha: 1.0)
        static let sunflower = UIColor(red: (241/255), green: (196/255), blue: (15/255), alpha: 1.0)
        static let pumpkin = UIColor(red: (211/255), green: (84/255), blue: (0/255), alpha: 1.0)
        static let asbestos = UIColor(red: (127/255), green: (140/255), blue: (141/255), alpha: 1.0)
        static let amethyst = UIColor(red: (155/255), green: (89/255), blue: (182/255), alpha: 1.0)
        static let peterRiver = UIColor(red: (52/255), green: (152/255), blue: (219/255), alpha: 1.0)
        static let pomegranate = UIColor(red: (192/255), green: (57/255), blue: (43/255), alpha: 1.0)
        
        static let all = [emerald, sunflower, pumpkin, asbestos, amethyst, peterRiver, pomegranate]
    }
    
    
//MARK: Array Constants
    struct Arrays {
        static let alphabets = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","#"] //# indicates the names with numbers and blank spaces
    }
    
}
