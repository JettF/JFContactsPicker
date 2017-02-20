//
//  ContactsPicker.swift
//  JFContactsPicker
//

import UIKit
import Contacts

public protocol ContactsPickerDelegate: class {
    func contactPicker(_: ContactsPicker, didContactFetchFailed error: NSError)
    func contactPicker(_: ContactsPicker, didCancel error: NSError)
    func contactPicker(_: ContactsPicker, didSelectContact contact: Contact)
    func contactPicker(_: ContactsPicker, didSelectMultipleContacts contacts: [Contact])
}

public extension ContactsPickerDelegate {
    func contactPicker(_: ContactsPicker, didContactFetchFailed error: NSError) { }
    func contactPicker(_: ContactsPicker, didCancel error: NSError) { }
    func contactPicker(_: ContactsPicker, didSelectContact contact: Contact) { }
    func contactPicker(_: ContactsPicker, didSelectMultipleContacts contacts: [Contact]) { }
}

typealias ContactsHandler = (_ contacts : [CNContact] , _ error : NSError?) -> Void

public enum SubtitleCellValue{
    case phoneNumber
    case email
    case birthday
    case organization
}

open class ContactsPicker: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    // MARK: - Properties
    
    public internal(set) var resultSearchController: UISearchController?
    public private(set) lazy var contactsStore: CNContactStore = { return CNContactStore() }()
    
    /// Contacts ordered in dictionary alphabetically using `sortOrder`.
    private var orderedContacts = [String: [CNContact]]()
    private var sortedContactKeys = [String]()
    
    public private(set) var selectedContacts = [Contact]()
    private var filteredContacts = [CNContact]()
    
    /// The `delegate` for the picker.
    open weak var contactDelegate: ContactsPickerDelegate?
    
    /// If `true`, the picker will allow multiple contacts to be selected.
    /// Defaults to `false` for single contact selection.
    public let multiSelectEnabled: Bool
    
    /// Indicates if the index bar should be shown. Defaults to `true`.
    public var shouldShowIndexBar: Bool
    
    /// The contact value type to display in the cells' subtitle labels.
    public let subtitleCellValue: SubtitleCellValue
    
    /// The order that the contacts should be sorted.
    public var sortOrder: CNContactSortOrder = CNContactSortOrder.userDefault {
        didSet {
            if viewIfLoaded != nil {
                self.reloadContacts()
            }
        }
    }
    
    //Enables custom filtering of contacts.
    public var shouldIncludeContact: ((CNContact) -> Bool)? {
        didSet {
            if viewIfLoaded != nil {
                self.reloadContacts()
            }
        }
    }
    
    // MARK: - Initializers
    
    // TODO: Document
    public init(delegate: ContactsPickerDelegate? = nil,
                multiSelection: Bool = false,
                showIndexBar: Bool = true,
                subtitleCellType: SubtitleCellValue = .phoneNumber) {
        self.multiSelectEnabled = multiSelection
        self.subtitleCellValue = subtitleCellType
        self.shouldShowIndexBar = showIndexBar
        
        super.init(style: .plain)
        
        contactDelegate = delegate
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.multiSelectEnabled = false
        self.subtitleCellValue = .phoneNumber
        self.shouldShowIndexBar = true
        
        super.init(coder: aDecoder)
    }
    
    // MARK: - Lifecycle Methods
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.title = GlobalConstants.Strings.contactsTitle
        
        registerContactCell()
        initializeBarButtons()
        initializeSearchBar()
        reloadContacts()
    }
    
    func initializeSearchBar() {
        self.resultSearchController = ( {
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.hidesNavigationBarDuringPresentation = false
            controller.searchBar.sizeToFit()
            controller.searchBar.delegate = self
            self.tableView.tableHeaderView = controller.searchBar
            return controller
        })()
    }
    
    func initializeBarButtons() {
        let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(onTouchCancelButton))
        self.navigationItem.leftBarButtonItem = cancelButton
        
        if multiSelectEnabled {
            let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(onTouchDoneButton))
            self.navigationItem.rightBarButtonItem = doneButton
            
        }
    }
    
    private func registerContactCell() {
        let podBundle = Bundle(for: self.classForCoder)
        if let bundleURL = podBundle.url(forResource: GlobalConstants.Strings.bundleIdentifier, withExtension: "bundle") {
            
            if let bundle = Bundle(url: bundleURL) {
                
                let cellNib = UINib(nibName: GlobalConstants.Strings.cellNibIdentifier, bundle: bundle)
                tableView.register(cellNib, forCellReuseIdentifier: "Cell")
            }
            else {
                assertionFailure("Could not load bundle")
            }
            
        } else {
            let cellNib = UINib(nibName: GlobalConstants.Strings.cellNibIdentifier, bundle: podBundle)
            tableView.register(cellNib, forCellReuseIdentifier: "Cell")
        }
    }
    
    // MARK: - Contact Operations
    
    open func reloadContacts() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.getContacts { [weak self] (contacts, error) in
                if (error == nil) {
                    DispatchQueue.main.async { [weak self] in
                        self?.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    private func getContacts(_ completion:  @escaping ContactsHandler) {
        // TODO: Set up error domain
        let error = NSError(domain: "EPContactPickerErrorDomain", code: 1, userInfo: [NSLocalizedDescriptionKey: "No Contacts Access"])
        
        switch CNContactStore.authorizationStatus(for: CNEntityType.contacts) {
        case CNAuthorizationStatus.denied, CNAuthorizationStatus.restricted:
            //User has denied the current app to access the contacts.
            
            let productName = Bundle.main.infoDictionary!["CFBundleName"]!
            
            let alert = UIAlertController(title: "Unable to access contacts", message: "\(productName) does not have access to contacts. Kindly enable it in privacy settings ", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {  action in
                self.contactDelegate?.contactPicker(self, didContactFetchFailed: error)
                completion([], error)
                self.dismiss(animated: true, completion: nil)
            })
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            
        case CNAuthorizationStatus.notDetermined:
            //This case means the user is prompted for the first time for allowing contacts
            contactsStore.requestAccess(for: CNEntityType.contacts, completionHandler: { (granted, error) -> Void in
                //At this point an alert is provided to the user to provide access to contacts. This will get invoked if a user responds to the alert
                if  (!granted ){
                    DispatchQueue.main.async(execute: { () -> Void in
                        completion([], error! as NSError?)
                    })
                }
                else{
                    self.getContacts(completion)
                }
            })
            
        case  CNAuthorizationStatus.authorized:
            //Authorization granted by user for this app.
            var contactsArray = [CNContact]()
            
            var orderedContacts = [String : [CNContact]]()
            
            let contactFetchRequest = CNContactFetchRequest(keysToFetch: allowedContactKeys())
            
            do {
                try contactsStore.enumerateContacts(with: contactFetchRequest, usingBlock: { [weak self] (contact, stop) -> Void in
                    
                    //Adds the `contact` to the `contactsArray` if the closure returns true.
                    //If the closure doesn't exist, then the contact is added.
                    if let shouldIncludeContactClosure = self?.shouldIncludeContact, !shouldIncludeContactClosure(contact) {
                        return
                    }
                    
                    contactsArray.append(contact)
                    
                    //Ordering contacts based on alphabets in firstname
                    var key: String = "#"
                    
                    //If ordering has to be happening via family name change it here.
                    if let firstLetter = self?.firstLetter(for: contact) {
                        key = firstLetter.uppercased()
                    }
                    
                    var contactsForKey = orderedContacts[key] ?? [CNContact]()
                    contactsForKey.append(contact)
                    orderedContacts[key] = contactsForKey
                    
                })
                
                self.orderedContacts = orderedContacts
                self.sortedContactKeys = Array(self.orderedContacts.keys).sorted(by: <)
                if self.sortedContactKeys.first == "#" {
                    self.sortedContactKeys.removeFirst()
                    self.sortedContactKeys.append("#")
                }
                completion(contactsArray, nil)
                
            } catch let error as NSError {
                /// Catching exception as enumerateContactsWithFetchRequest can throw errors
                print(error.localizedDescription)
            }
            
        }
    }
    
    private func firstLetter(for contact: CNContact) -> String? {
        var firstLetter: String? = nil
        
        switch sortOrder {
            
        case .userDefault where CNContactsUserDefaults.shared().sortOrder == .familyName:
            fallthrough
        case .familyName:
            firstLetter = contact.familyName[0..<1]
            
        case .userDefault where CNContactsUserDefaults.shared().sortOrder == .givenName:
            fallthrough
        case .givenName:
            fallthrough
        default:
            firstLetter = contact.givenName[0..<1]
        }
        
        guard let letter = firstLetter, letter.containsAlphabets() else { return nil }
        return letter
    }
    
    func allowedContactKeys() -> [CNKeyDescriptor]{
        //We have to provide only the keys which we have to access. We should avoid unnecessary keys when fetching the contact. Reducing the keys means faster the access.
        return [CNContactNamePrefixKey as CNKeyDescriptor,
                CNContactGivenNameKey as CNKeyDescriptor,
                CNContactFamilyNameKey as CNKeyDescriptor,
                CNContactOrganizationNameKey as CNKeyDescriptor,
                CNContactBirthdayKey as CNKeyDescriptor,
                CNContactImageDataKey as CNKeyDescriptor,
                CNContactThumbnailImageDataKey as CNKeyDescriptor,
                CNContactImageDataAvailableKey as CNKeyDescriptor,
                CNContactPhoneNumbersKey as CNKeyDescriptor,
                CNContactEmailAddressesKey as CNKeyDescriptor,
        ]
    }
    
    // MARK: - Table View DataSource
    
    override open func numberOfSections(in tableView: UITableView) -> Int {
        if let searchController = resultSearchController, searchController.isActive { return 1 }
        return sortedContactKeys.count
    }
    
    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let searchController = resultSearchController, searchController.isActive {
            return filteredContacts.count
        }
        
        if let contactsForSection = orderedContacts[sortedContactKeys[section]] {
            return contactsForSection.count
        }
        
        return 0
    }
    
    // MARK: - Table View Delegates
    
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ContactCell
        cell.accessoryType = UITableViewCellAccessoryType.none
        //Convert CNContact to Contact
        let contact: Contact
        
        if let searchController = resultSearchController, searchController.isActive {
            contact = Contact(contact: filteredContacts[(indexPath as NSIndexPath).row])
            
        } else {
            guard let contactsForSection = orderedContacts[sortedContactKeys[(indexPath as NSIndexPath).section]] else {
                assertionFailure()
                return UITableViewCell()
            }
            
            contact = Contact(contact: contactsForSection[(indexPath as NSIndexPath).row])
        }
        
        if multiSelectEnabled  && selectedContacts.contains(where: { $0.contactId == contact.contactId }) {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        }
        
        cell.updateContactsinUI(contact, indexPath: indexPath, subtitleType: subtitleCellValue)
        return cell
    }
    
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! ContactCell
        let selectedContact =  cell.contact!
        if multiSelectEnabled {
            //Keeps track of enable=ing and disabling contacts
            if cell.accessoryType == UITableViewCellAccessoryType.checkmark {
                cell.accessoryType = UITableViewCellAccessoryType.none
                selectedContacts = selectedContacts.filter(){
                    return selectedContact.contactId != $0.contactId
                }
            }
            else {
                cell.accessoryType = UITableViewCellAccessoryType.checkmark
                selectedContacts.append(selectedContact)
            }
        }
        else {
            //Single selection code
            if let searchController = resultSearchController, searchController.isActive {
                searchController.isActive = false
            }
            
			self.contactDelegate?.contactPicker(self, didSelectContact: selectedContact)
        }
    }
    
    override open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    override open func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if let searchController = resultSearchController, searchController.isActive { return 0 }
        
        return sortedContactKeys.index(of: title)!
    }
    
    override open func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if shouldShowIndexBar {
            if let searchController = resultSearchController, searchController.isActive { return nil }
            
            return sortedContactKeys
            
        } else {
            return nil
        }
    }
    
    override open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let searchController = resultSearchController, searchController.isActive { return nil }
        
        return sortedContactKeys[section]
    }
    
    // MARK: - Button Actions
    
    func onTouchCancelButton() {
        // TODO: Set up errors
        contactDelegate?.contactPicker(self, didCancel: NSError(domain: "JFContactsPickerErrorDomain",
                                                                code: 2,
                                                                userInfo: [ NSLocalizedDescriptionKey: "User Canceled Selection"]))
    }
    
    func onTouchDoneButton() {
        contactDelegate?.contactPicker(self, didSelectMultipleContacts: selectedContacts)
    }
    
    // MARK: - Search Actions
    
    open func updateSearchResults(for searchController: UISearchController)
    {
        if let searchText = resultSearchController?.searchBar.text , searchController.isActive {
            
            let predicate: NSPredicate
            if searchText.characters.count > 0 {
                predicate = CNContact.predicateForContacts(matchingName: searchText)
            } else {
                predicate = CNContact.predicateForContactsInContainer(withIdentifier: contactsStore.defaultContainerIdentifier())
            }
            
            let store = CNContactStore()
            do {
                filteredContacts = try store.unifiedContacts(matching: predicate,
                                                             keysToFetch: allowedContactKeys())
                if let shouldIncludeContact = shouldIncludeContact {
                    filteredContacts = filteredContacts.filter(shouldIncludeContact)
                }
                
                self.tableView.reloadData()
                
            }
            catch {
                print("Error!")
            }
        }
    }
    
    open func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
}
