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

import HatForIOS
import SwiftyJSON

// MARK: Class

internal class DataStoreHappinessAndMentalHealthTableViewController: UITableViewController, UserCredentialsProtocol {
    
    // MARK: - Variables
    
    /// The sections of the table view
    private let sections: [[String]] = [["Personal Habits"], ["My own behavior For Happiness"], ["Interpersonal Relationships And Happiness"]]
    private let header: String = "Please indicate how important from 1 (not at all) to 5 (very much)"
    
    private var surveyObjects: [SurveyObject] = []
    
    private var loadingView: UIView?
    
    // MARK: - IBActions
    
    @IBAction func saveHabits(_ sender: Any) {
        
        func success(json: JSON, newToken: String?) {
            
            self.loadingView?.removeFromSuperview()
            self.tableView.isUserInteractionEnabled = true
            _ = self.navigationController?.popViewController(animated: true)
        }
        
        self.tableView.isUserInteractionEnabled = false
        self.loadingView = UIView.createLoadingView(
            with: CGRect(x: (self.tableView?.frame.midX)! - 70, y: (self.tableView?.frame.midY)! - 15, width: 160, height: 30),
            color: .accentColor,
            cornerRadius: 15,
            in: self.view,
            with: "Saving Savy data...",
            textColor: .white,
            font: UIFont(name: Constants.FontNames.openSans, size: 12)!)
        
        for index in self.sections.indices {
            
            var cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: index)) as? SurveyTableViewCell
            
            if cell == nil {
                
                let indexPath = IndexPath(row: 0, section: index)
                cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellReuseIDs.happinesAndMentalHealthCell, for: indexPath) as? SurveyTableViewCell
                cell = self.setUpCell(cell: cell!, indexPath: indexPath) as? SurveyTableViewCell
            }
            
            if self.surveyObjects.count < index {
                
                self.surveyObjects.append(SurveyObject())
            }
            self.surveyObjects[index].answer = (cell?.getSelectedAnswer())!
        }
        
        var array: [Dictionary<String, Any>] = []
        for survey in surveyObjects {
            
            array.append(survey.toJSON())
        }
        
        HATAccountService.createTableValuev2(
            token: userToken,
            userDomain: userDomain,
            source: Constants.HATTableName.HappinessAndMentalHealthAnswers.source,
            dataPath: Constants.HATTableName.HappinessAndMentalHealthAnswers.name,
            parameters: ["array": array,
                         "unixTimeStamp": SurveyObject.createUnixTimeStamp()],
            successCallback: success,
            errorCallback: accessingHATTableFail)
    }
    
    // MARK: - Auto generated methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.getSurveyQuestionsAndAnswers()
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.sections[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellReuseIDs.happinesAndMentalHealthCell, for: indexPath) as? SurveyTableViewCell
        
        return self.setUpCell(cell: cell!, indexPath: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return header
    }
    
    // MARK: - Update cell
    
    /**
     Sets up the cell accordingly
     
     - parameter cell: The cell to set up
     - parameter indexPath: The index path of the cell
     
     - returns: The set up cell
     */
    func setUpCell(cell: SurveyTableViewCell, indexPath: IndexPath) -> UITableViewCell {
        
        cell.setQuestionInLabel(question: self.sections[indexPath.section][indexPath.row])
        if self.surveyObjects.count > indexPath.section {
            
            cell.setSelectedAnswer(self.surveyObjects[indexPath.section + indexPath.row].answer)
        } else {
            
            var surveyObject = SurveyObject()
            surveyObject.question = self.sections[indexPath.section][indexPath.row]
            
            self.surveyObjects.append(surveyObject)
        }
        
        return cell
    }
    
    // MARK: - Get Survey questions
    
    /**
     Logs the error with the fabric
     
     - parameter error: The HATTableError returned from hat
     */
    func accessingHATTableFail(error: HATTableError) {
        
        self.tableView.isUserInteractionEnabled = false
        self.loadingView?.removeFromSuperview()
        self.createClassicOKAlertWith(
            alertMessage: "The was an error saving the data to Savy",
            alertTitle: "Error",
            okTitle: "OK",
            proceedCompletion: {})
        CrashLoggerHelper.hatTableErrorLog(error: error)
    }
    
    /**
     Get questions from hat
     */
    private func getSurveyQuestionsAndAnswers() {
        
        func gotValues(jsonArray: [JSON], newToken: String?) {
            
            self.tableView.isUserInteractionEnabled = true
            self.loadingView?.removeFromSuperview()
            
            if !jsonArray.isEmpty {
                
                self.surveyObjects.removeAll()
                
                if let array = jsonArray[0].dictionary?["data"]?["array"].array {
                    
                    for item in array {
                        
                        self.surveyObjects.append(SurveyObject(from: item))
                    }
                }
                
                self.tableView.reloadData()
            }
        }
        
        self.loadingView?.removeFromSuperview()
        self.loadingView = UIView.createLoadingView(
            with: CGRect(x: (self.tableView?.frame.midX)! - 70, y: (self.tableView?.frame.midY)! - 15, width: 160, height: 30),
            color: .accentColor,
            cornerRadius: 15,
            in: self.view,
            with: "Loading Savy data...",
            textColor: .white,
            font: UIFont(name: Constants.FontNames.openSans, size: 12)!)
        
        HATAccountService.getHatTableValuesv2(
            token: userToken,
            userDomain: userDomain,
            source: Constants.HATTableName.HappinessAndMentalHealthAnswers.source,
            scope: Constants.HATTableName.HappinessAndMentalHealthAnswers.name,
            parameters: ["take": "1", "orderBy": "unixTimeStamp", "ordering": "descending"],
            successCallback: gotValues,
            errorCallback: accessingHATTableFail)
    }
    
}
