//
//  CourseGameViewController.swift
//  GolfTourney
//
//  Created by Dirk Milotz on 2/10/17.
//  Copyright © 2017 Dirk Milotz. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import THCalendarDatePicker

class CourseGameViewController : UIViewController {
  
  //MARK: - Properties
  var extraCourseInfo: [String: AnyObject]?
  var course: Course?
  var games: [Game] = []
  var gamesIdArr: [String]?
  var game: Game?
  var photo: UIImage?
  
  var curFromDate : Date? = Date()
  let daysToAdd : TimeInterval = 10
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

  
   //MARK: - Outlets
  @IBOutlet var dateButton: UIButton!
  @IBOutlet var courseName: UILabel!
  @IBOutlet var courseAddress: UILabel!
  @IBOutlet var numberOfHoles: UILabel!
  @IBOutlet var yearBuilt: UILabel!
  @IBOutlet var designer: UILabel!
  @IBOutlet var courseImage: UIImageView!
  @IBOutlet var buyInAmount: UILabel!
  @IBOutlet var buyInStepper: UIStepper!
  
  
  
  //MARK: - Overridden methods
  
  override var shouldAutorotate: Bool {
    return false
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if let vc = segue.destination as? GameViewController{
        vc.courseImage = courseImage.image
        vc.game = self.game
      }
    
  }
  
}

//MARK: - Actions
extension CourseGameViewController{
  
  @IBAction func goToWebsite(_ sender: Any) {
    if let url = extraCourseInfo?["websiteUrl"] as? URL{
      UIApplication.shared.openURL(url)
    }
    else{
      let alertController = UIAlertController(title: "Url Error", message:
        "No website provided for this course.", preferredStyle: UIAlertControllerStyle.alert)
      alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
      
      self.present(alertController, animated: true, completion: nil)
    }
  }
}


// MARK: - Lifecycle
extension CourseGameViewController{
  override func viewDidLoad() {
    super.viewDidLoad()
    buyInStepper.maximumValue = 10
    buyInStepper.minimumValue = 0
    setUp()
  }
}

extension CourseGameViewController{
  @IBAction func createGame(_ sender: Any) {
    setupGame()
    //self.displayAlert("Game has been created at \(courseName.text)!", title: "Game Created!")
    let vc = self.storyboard?.instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
    vc.courseImage = courseImage.image
    vc.game = self.game!
    self.navigationController?.pushViewController(vc, animated: true)
  }
  

  
  @IBAction func buyInStepper(_ sender: UIStepper) {
    buyInAmount.text = "$\(Int(sender.value))"
  }
  
}



//MARK: - private methods
private extension CourseGameViewController{
  func setUp(){
    courseName.text = course?.biz_name
    courseAddress.text = "\(course!.e_address), \(course!.e_city), \(course!.e_state)"
    numberOfHoles.text = "Holes: \(course!.c_holes)"
    yearBuilt.text = "Year Built: \(course!.year_built)"
    designer.text = "Designer: \(course!.c_designer)"
    courseImage.image = extraCourseInfo?["image"] as! UIImage?
  }
  
}


// MARK: - THDatePickerDelegate

extension CourseGameViewController: THDatePickerDelegate {
  
  
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

private extension CourseGameViewController{
  
  func setupGame(){
    let buyIn = Int((buyInAmount.text?.replacingOccurrences(of: "$", with: ""))!)
    let curUser = FIRAuth.auth()?.currentUser?.uid
    var websiteString: String = ""
    if let websiteUrl = extraCourseInfo?["courseWebsiteUrl"] as? URL{
      websiteString = websiteUrl.absoluteString
    }else{
      websiteString = ""
    }
    let titleText: String = ""
    
    self.game = Game(gameId: UUID().uuidString, preferredHandicap: "", courseName: course!.biz_name.replacingOccurrences(of: ".", with: ""), courseId: String(describing: course!.id), courseAddress: "\(course!.e_address), \(course!.e_city), \(course!.e_state)", date:formatter.string(from: curFromDate!), players: [curUser!: ""], buyIn: buyIn, description: titleText, maxPlayers: 20, currentPlayerCount: 1, currentPot: buyIn, gameOwner: curUser, coursePicUrl: extraCourseInfo?["coursePicUrl"] as? String, courseWebsiteUrl: websiteString)
    NetworkClient.createGame(self.game!) { (message, error) in

    }
  }
  
}


