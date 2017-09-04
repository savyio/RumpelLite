/**
 * Copyright (C) 2017 HAT Data Exchange Ltd
 *
 * SPDX-License-Identifier: MPL2
 *
 * This file is part of the Hub of All Things project (HAT).
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/
 */

import UIKit

// MARK: Class

/// A class responsible for handling the phata table view cell
internal class PhataTableViewCell: UITableViewCell, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: - Variables
    
    /// The options of the picker view
    var dataSourceForPickerView: [String] = ["", "Mr.", "Mrs.", "Miss", "Dr."]
    
    // MARK: - IBOutlets
    
    /// An IBOutlet for handling the switch
    @IBOutlet private weak var privateSwitch: CustomSwitch!
    
    /// An IBOutlet for handling the textField
    @IBOutlet private weak var textField: UITextField!
    /// An IBOutlet for handling the textView
    @IBOutlet private weak var textView: UITextView!
    
    // MARK: - PickerView methods
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return dataSourceForPickerView.count
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return dataSourceForPickerView[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        self.textField.text = self.dataSourceForPickerView[row]
    }
    
    // MARK: - TableViewCell methods
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        self.textView?.delegate = self
        self.textField?.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Picker did update date
    
    /**
     Updates the textField according to the selection of the datePicker
     
     - parameter datePicker: The datePicker that called this method
     */
    func datePickerDidUpdateDate(datePicker: UIDatePicker) {
        
        self.textField.text = FormatterHelper.formatDateStringToUsersDefinedDate(
            date: datePicker.date,
            dateStyle: .short,
            timeStyle: .none)
    }
    
    // MARK: - TextField delegate method
    
    func textFieldValueChanged(textField: UITextField) {
        
        if textField.tag == 5 {
            
            var text = textField.text!
            var cursorPosition: Int = 0
            
            if let selectedRange = textField.selectedTextRange {
                
                cursorPosition = textField.offset(from: textField.beginningOfDocument, to: selectedRange.start)
                
                let index = text.index(text.startIndex, offsetBy: cursorPosition)
                text = text.substring(to: index)
            }
            
            let countries = self.getCountries()
            var found = false
            
            for country in countries where !text.characters.isEmpty {
                
                if country.lowercased().hasPrefix(text.lowercased()) {
                    
                    let partOne = text.createTextAttributes(
                        foregroundColor: .black,
                        strokeColor: .black,
                        font: UIFont(name: Constants.FontNames.openSans, size: 14)!)
                    
                    let replacedText = country.lowercased().replacingOccurrences(of: text.lowercased(), with: "")
                    let partTwo = replacedText.createTextAttributes(
                        foregroundColor: .gray,
                        strokeColor: .gray,
                        font: UIFont(name: Constants.FontNames.openSans, size: 14)!)
                    textField.attributedText = partOne.combineWith(attributedText: partTwo)
                    
                    if let newPosition = textField.position(from: textField.beginningOfDocument, offset: cursorPosition) {
                        
                        textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
                    }
                    
                    found = true
                    break
                }
            }
            
            if !found {
                
                textField.text = text
            }
            
            if text.characters.count < 1 {
                
                textField.text = ""
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField.tag == 5 {
            
            let stringToFind = textField.attributedText?.string
            
            let countries = self.getCountries()
            
            for i in 0...countries.count - 1 {
                
                if countries[i].lowercased() == stringToFind?.lowercased() {
                    
                    textField.text = countries[i]
                    break
                }
            }
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField.tag == 15 || textField.tag == 10 || textField.tag == 11 {
            
            let pickerView = UIPickerView()
            pickerView.delegate = self
            pickerView.dataSource = self
            textField.inputView = pickerView
        } else if textField.tag == 12 {
            
            let datePickerView = UIDatePicker()
            datePickerView.addTarget(self, action: #selector(datePickerDidUpdateDate(datePicker:)), for: .valueChanged)

            datePickerView.locale = .current
            datePickerView.datePickerMode = .date
            textField.inputView = datePickerView
            let date = FormatterHelper.formatStringToDate(string: textField.text!)
            if date != nil {
                
                datePickerView.setDate(date!, animated: true)
            }
            textField.text = FormatterHelper.formatDateStringToUsersDefinedDate(
                date: datePickerView.date,
                dateStyle: .short,
                timeStyle: .none)
        }
        
        return true
    }
    
    // MARK: - Find Row in picker view for this item
    
    /**
     Searches and returns the position of a string in the data source of the picker view
     
     - parameter item: The item we are looking for
     
     - returns: 0 if not found else the index of the string in the array
     */
    private func getRowForItemInDataSource(item: String?) -> Int {
        
        var isFound = false

        for (index, dataItem) in self.dataSourceForPickerView.enumerated() where item != nil {
            
            if item!.lowercased() == dataItem.lowercased() {
                
                isFound = true
                return index
            }
        }
        
        if !isFound {
            
            return 0
        }
    }
    
    // MARK: - Get text from textField
    
    /**
     Returns the text in the UITextField or empty string if there is no text
     
     - returns: A Sting the text in the UITextField
     */
    func getTextFromTextField() -> String {
        
        if self.textField != nil {
            
            return self.textField.text!
        } else if self.textView != nil {
            
            return self.textView.text
        }
        
        return ""
    }
    
    // MARK: - Get switch value
    
    /**
     Returns the UISwitch position state as a Bool
     
     - returns: Returns the UISwitch position state as a Bool
     */
    func getSwitchValue() -> Bool {
        
        return self.privateSwitch.isOn
    }
    
    // MARK: - Set text from textField
    
    /**
     Sets the text passed as paramter to the UITextField
     
     - parameter text: The text to insert in the UITextField
     */
    func setTextToTextField(text: String) {
        
        if self.textField != nil {
            
            self.textField.text = text
        } else if self.textView != nil {
            
            self.textView.text = text
        }
    }
    
    // MARK: - Set switch value
    
    /**
     Sets the state of thw switch
     
     - parameter isOn: A Bool value indicating if the switch is on or not
     */
    func setSwitchValue(isOn: Bool) {
        
        return self.privateSwitch.isOn = isOn
    }
    
    // MARK: - Hide switch
    
    /**
     Hides the UISwitch
     
     - parameter isHidden: A Bool value indicating if the switch is hidden or not
     */
    func isSwitchHidden(_ isHidden: Bool) {
        
        self.privateSwitch.isHidden = isHidden
    }
    
    // MARK: - Set delegate
    
    /**
     Sets the delegate to the UITextField
     
     - parameter delegate: The delegate viewController
     */
    func setDelegate(delegate: UITextFieldDelegate) {
        
        self.textField.delegate = delegate
    }
    
    // MARK: - Set Keyboard Type
    
    /**
     Sets the keyboard type in the UITextField
     
     - parameter keyboardType: The type of the keyboard for the UITextField
     */
    func setKeyboardType(_ keyboardType: UIKeyboardType) {
        
        self.textField.keyboardType = keyboardType
    }
    
    // MARK: - Set Tag in textfield
    
    /**
     Sets the tag number in the UITextField
     
     - parameter tag: The tag to add to the UITextField
     */
    func setTagInTextField(tag: Int) {
        
        self.textField.tag = tag
        if tag == 5 {
            
            self.textField.addTarget(self, action: #selector(self.textFieldValueChanged(textField:)), for: UIControlEvents.allEditingEvents)
        }
    }
    
    // MARK: - Set text color in textField
    
    /**
     Sets the text color in the UITextField
     
     - parameter color: The color to set for the text
     */
    func setTextColorInTextField(color: UIColor) {
        
        if self.textField != nil {
            
            self.textField.textColor = color
        } else if self.textView != nil {
            
            self.textView.textColor = color
        }
    }
    
    // MARK: - Make textview link clickable
    
    /**
     Sets up textView with the url
     
     - parameter string: The url to show on the textView
     */
    func enableLink(string: String) {
        
        self.textView.text = string
        self.textView.textColor = .accentColor
    }
    
    // MARK: - Get countries
    
    /**
     Gets all the countries available
     
     - returns: An array of strings for the countries found
     */
    private func getCountries() -> [String] {
        
        let locale: NSLocale = NSLocale.current as NSLocale
        let countryArray = Locale.isoRegionCodes
        let unsortedCountryArray: [String] = countryArray.map { (countryCode) -> String in
            
            locale.displayName(forKey: NSLocale.Key.countryCode, value: countryCode)!
        }
        
        return unsortedCountryArray.sorted()
    }
}
