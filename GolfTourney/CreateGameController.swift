//
//  CreateGameController.swift
//  GolfTourney
//
//  Created by Dirk Milotz on 2/13/17.
//  Copyright © 2017 Dirk Milotz. All rights reserved.
//

import Foundation
import UIKit
import THCalendarDatePicker
import FirebaseAuth
import FirebaseDatabase

class CreateGameController: UIViewController{
  // MARK: Properties
  
  var ref: FIRDatabaseReference!
  var handicapPickerDataSource = ["Low Handicap 0-10", "Mid Handicap 10-20", "High Handicap 20-30"]
  var extraCourseInfo: [String: AnyObject]?
  var chosenHandicap: String?
  var course = Course()
  var curFromDate : Date? = Date()
  let daysToAdd : TimeInterval = 10
  var photoUrl : URL?
  var golfSlogans : [String] = ["Grip it and rip it", "Clubbing at its best!", "Golf strong, go long", "Play the course not your opponent", "Arnie would do it", "A bad attitude is worse than a bad swing.", "Don’t fear the bogey man.", "The most important shot in golf is the next one."]
  
  lazy var formatter: DateFormatter = {
    var tmpFormatter = DateFormatter()
    tmpFormatter.dateFormat = "MM/dd/yyyy"
    return tmpFormatter
  }()
  
  lazy var fromDatePicker : THDatePickerViewController = {
    let picker = THDatePickerViewController.datePicker()
    picker?.delegate = self
    picker?.date = self.curFromDate
    picker?.selectedBackgroundColor = UIColor.brown
    picker?.currentDateColor = UIColor.orange
    picker?.currentDateColorSelected = UIColor.yellow
    return picker!
  }()
  
  // MARK: Outlets
  
  @IBOutlet var courseName: UILabel!
  //@IBOutlet var tourneyTitle: UITextView!
  @IBOutlet var buyInAmountLabel: UILabel!
  @IBOutlet weak var dateButton: UIButton!
  @IBOutlet var buyInStepper: UIStepper!
  @IBOutlet var handicapPicker: UIPickerView!
  
  
  override var shouldAutorotate: Bool {
    return false
  }
  
}



// MARK: Lifecycle Methods

extension CreateGameController{
  
  override func viewDidLoad() {
    super.viewDidLoad()
    //tourneyTitle.delegate = self
    chosenHandicap = handicapPickerDataSource[0]
    buyInStepper.maximumValue = 10
    buyInStepper.minimumValue = 0
    refreshTitle()
    handicapPicker.delegate = self
    handicapPicker.dataSource = self
    courseName.text = course.biz_name
    ref = FIRDatabase.database().reference()
    
  }
}

// MARK: Actions

extension CreateGameController{
  @IBAction func createGame(_ sender: Any) {
    setupGame()
    //self.displayAlert("Game has been created at \(courseName.text)!", title: "Game Created!")
    let controller = self.storyboard?.instantiateViewController(withIdentifier: "TabController")
    self.present(controller!, animated: true, completion: nil)
  }
  
  @IBAction func cancel(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func buyInStepper(_ sender: UIStepper) {
    buyInAmountLabel.text = "$\(Int(sender.value))"
  }
  
}


extension CreateGameController: UITextViewDelegate{
  func textViewDidBeginEditing(_ textView: UITextView) {
    textView.text = ""
  }
  
}


// MARK: - Picker delegate used for handicap picker

extension CreateGameController: UIPickerViewDelegate, UIPickerViewDataSource{
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return handicapPickerDataSource.count
  }
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return handicapPickerDataSource[row]
  }
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    chosenHandicap = handicapPickerDataSource[row]
  }
  
}

// MARK: - THDatePickerDelegate

extension CreateGameController: THDatePickerDelegate {
  
  
  func refreshTitle() {
    dateButton.setTitle((curFromDate != nil ? formatter.string(from: curFromDate!) : "No date selected"), for: UIControlState())
  }
  
  @IBAction func touchedButton(_ sender: AnyObject) {
    if (sender.tag == 10) {
      fromDatePicker.date = self.curFromDate
      //            fromDatePicker.setDateRangeFrom(self.curFromDate, to: self.curToDate)
      
      presentSemiViewController(fromDatePicker, withOptions: [
        convertCfTypeToString(KNSemiModalOptionKeys.shadowOpacity) as String! : 0.3 as Float,
        convertCfTypeToString(KNSemiModalOptionKeys.animationDuration) as String! : 1.0 as Float,
        convertCfTypeToString(KNSemiModalOptionKeys.pushParentBack) as String! : false as Bool
        ])
    }
  }
  
  /* https://vandadnp.wordpress.com/2014/07/07/swift-convert-unmanaged-to-string/ */
  func convertCfTypeToString(_ cfValue: Unmanaged<NSString>!) -> String?{
    /* Coded by Vandad Nahavandipoor */
    let value = Unmanaged<CFString>.fromOpaque(
      cfValue.toOpaque()).takeUnretainedValue() as CFString
    if CFGetTypeID(value) == CFStringGetTypeID(){
      return value as String
    } else {
      return nil
    }
  }
  
  func datePickerDonePressed(_ datePicker: THDatePickerViewController!) {
    if datePicker == fromDatePicker {
      curFromDate = datePicker.date
    }
    refreshTitle()
    dismissSemiModalView()
  }
  
  func datePickerCancelPressed(_ datePicker: THDatePickerViewController!) {
    dismissSemiModalView()
  }
  
  func datePicker(_ datePicker: THDatePickerViewController!, selectedDate: Date!) {
    print("Date selected: ", formatter.string(from: selectedDate))
  }
}

// MARK: Private Methods

private extension CreateGameController{
  
  func setupGame(){
    let buyIn = Int((buyInAmountLabel.text?.replacingOccurrences(of: "$", with: ""))!)
    let curUser = FIRAuth.auth()?.currentUser?.uid
    var websiteString: String = ""
    if let websiteUrl = extraCourseInfo?["courseWebsiteUrl"] as? URL{
      websiteString = websiteUrl.absoluteString
    }else{
      websiteString = ""
    }
    var titleText: String = ""
    
    let game = Game(gameId: UUID().uuidString, preferredHandicap: chosenHandicap!, courseName: course.biz_name.replacingOccurrences(of: ".", with: ""), courseId: String(course.id), courseAddress: "\(course.e_address), \(course.e_city), \(course.e_state)", date:formatter.string(from: curFromDate!), players: [curUser!: ""], buyIn: buyIn, description: titleText, maxPlayers: 20, currentPlayerCount: 1, currentPot: buyIn, gameOwner: curUser, coursePicUrl: extraCourseInfo?["coursePicUrl"] as? String, courseWebsiteUrl: websiteString)
    NetworkClient.createGame(game)
  }
  
}

