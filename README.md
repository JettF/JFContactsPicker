<p align="center" >
  <img src="Logo.jpg" alt="JFContactsPicker" title="JFContactsPicker" width="196">
</p>

# JFContactsPicker
A contacts picker component using Apple's Contacts framework.

[![Platform](https://img.shields.io/cocoapods/p/JFContactsPicker.svg?style=flat)](http://cocoapods.org/pods/JFContactsPicker)
[![Swift 4.2](https://img.shields.io/badge/Swift-4.2-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/JFContactsPicker.svg?style=flat)](http://cocoadocs.org/docsets/JFContactsPicker)
[![CI Status](https://travis-ci.org/jettf/JFContactsPicker.svg?branch=master)](https://travis-ci.org/jettf/JFContactsPicker)
[![License](https://img.shields.io/cocoapods/l/Ouroboros.svg?style=flat)](https://github.com/jettf/JFContactsPicker/blob/master/LICENSE)
[![Twitter: @JettFDev](https://img.shields.io/badge/contact-@JettFDev-blue.svg?style=flat)](https://twitter.com/JettFDev)
[![Twitter: @AnthonyMDev](https://img.shields.io/badge/contact-@AnthonyMDev-blue.svg?style=flat)](https://twitter.com/AnthonyMDev)

This library was originally forked from [EPContactsPicker](https://github.com/ipraba/EPContactsPicker), which is no longer maintained.

## Preview
![Single Selection](https://raw.githubusercontent.com/jettf/JFContactsPicker/master/Screenshots/Screen1.png)![Multi Selection](https://raw.githubusercontent.com/jettf/JFContactsPicker/master/Screenshots/Screen2.png)

## Installation

### CocoaPods
JFContactsPicker is available on CocoaPods. Just add the following to your project Podfile:

`pod 'JFContactsPicker', '~> 2.0'`

### Manual Installation

Just drag and drop the `Source` folder into your project

## Requirements

* iOS9+
* Swift 4.2
* ARC

For manual installation you may need to add these frameworks in your Build Phases:
`ContactsUI.framework` and `Contacts.framework`.

## Features

JFContacts Picker provides all common functionality and customization features:

[x] Single selection and multi-selection options.
[x] Search Contacts
[x] Configure the contact data to be shown. (Phone Number, Email, Birthday, or Organization)
[x] Section indexes to easily navigate through the contacts.
[x] Shows initials when image is not available.
[x] Contact object to get the properties of the contacts

If you would like additional support for additional customization features, please [Create a New Issue](https://github.com/JettF/JFContactsPicker/issues/new). 

## Initialization

Initialize the picker by passing the delegate, multiselection option, and the secondary data type to be displayed (Phone Number, Email, Birthday, or Organization). 

    let contactPicker = ContactsPicker(delegate: self, multiSelection:false, subtitleCellType: .email)
    let navigationController = UINavigationController(rootViewController: contactPicker)
    self.present(navigationController, animated: true, completion: nil)

## Delegates

ContactsPicker provides you four delegate methods for responding to the picker's events.

```swift
func contactPicker(_: ContactsPicker, didContactFetchFailed error : NSError)
func contactPicker(_: ContactsPicker, didCancel error : NSError)
func contactPicker(_: ContactsPicker, didSelectContact contact : Contact)
func contactPicker(_: ContactsPicker, didSelectMultipleContacts contacts : [Contact])
```

## Contact Object

The `Contact` object provides you the properties of a contact. This contains properties like displayName, initials, firstName, lastName, company, birthday, etc.

## License

JFContactsPicker is available under the MIT license. See the [LICENSE](https://github.com/jettf/JFContactsPicker/blob/master/LICENSE) file for more info.

## Contributors

[@JettF](https://github.com/JettF)  
[@AnthonyMDev](https://github.com/AnthonyMDev)  

*Original Authors*  
[@ipraba](https://github.com/ipraba)  
[@Sorix](https://github.com/Sorix)
