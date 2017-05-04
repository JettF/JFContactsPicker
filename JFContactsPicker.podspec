Pod::Spec.new do |s|
  s.name             = "JFContactsPicker"
  s.module_name      = "JFContactsPicker"
  s.version          = "1.0.3"
  s.summary          = "A contacts picker component for iOS written in swift using new contacts framwork. Forked from 'EPContactsPicker'."
  s.description      = <<-DESC
Features
[x] Single selection and multi-selection options.
[x] Search Contacts
[x] Configure the contact data to be shown. (Phone Number, Email, Birthday, or Organization)
[x] Section indexes to easily navigate through the contacts.
[x] Shows initials when image is not available.
[x] Contact object to get the properties of the contacts
DESC

  s.homepage         = "https://github.com/JettF/JFContactsPicker"
  s.license          = 'MIT'
  s.authors          = { "Jett Farmer" => "JettFarmer@gmail.com",
                         "Anthony Miller" => "AnthonyMDev@gmail.com"}
  s.source           = { :git => "https://github.com/jettf/JFContactsPicker.git", :tag => s.version.to_s }
  s.platform     = :ios, '9.0'
  s.requires_arc = true

  s.frameworks = 'Contacts', 'ContactsUI'

  s.source_files = 'Source'
  s.resource_bundles = { 'JFContactsPicker' => ['Assets/*.xib'] }

end
