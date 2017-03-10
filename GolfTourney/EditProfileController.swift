//
//  EditProfileController.swift
//  GolfTourney
//
//  Created by Dirk Milotz on 2/20/17.
//  Copyright © 2017 Dirk Milotz. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import UIKit

class EditProfileController: UIViewController{
  
  //MARK: Properties
  var ref: FIRDatabaseReference!
  let uid = FIRAuth.auth()?.currentUser?.uid
  var user: Player?
  var valsToUpdate: [String:String] = [:]
  var nameFieldButtonPressed: Bool = false
  var emailFieldButtonPressed: Bool = false
  
  
  //MARK: Outlets
  @IBOutlet var profileImage: UIImageView!
  @IBOutlet var nameField: UITextField!
  @IBOutlet var emailField: UITextField!
  @IBOutlet var handicapField: UITextField!
  @IBOutlet var zipField: UITextField!
  
  override var shouldAutorotate: Bool {
    return false
  }
}

//MARK: Actions

extension EditProfileController{
  @IBAction func changeProfileImage(_ sender: Any) {
    handleSelectProfileImage()
  }
  
  @IBAction func cancel(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func save(_ sender: UIButton) {
    updateUserInfoInDatabase()
  }
  @IBAction func editName(_ sender: Any) {
    nameFieldButtonPressed = true
  }
  
  @IBAction func editEmail(_ sender: Any) {
    emailFieldButtonPressed = true
  }
}


//MARK: Lifecycle
extension EditProfileController{
  
  override func viewDidLoad() {
    super.viewDidLoad()
    ref = FIRDatabase.database().reference()
    nameField.delegate = self
    emailField.delegate = self
    handicapField.delegate = self
    zipField.delegate = self
    subscribeToKeyboardNotifications()
    getUserInfo()
  }
  
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    unsubscribeFromKeyboardNotifications()
    ModalTransitionMediator.instance.sendPopoverDismissed(modelChanged: true)
  }
}

//MARK: Private methods

extension EditProfileController{
  func getUserInfo(){
    NetworkClient.getUserInfo(userId: uid!) { (dict, error) in
      if error == nil{
        self.user = Player(dict: dict!)
        self.setProfileFields()
      }
      else{
        self.displayAlert(error as! String, title: "Error")
      }
      
    }
  }
  
  func setProfileFields(){
    emailField.text = user!.email
    nameField.text = user!.name
    handicapField.text = user!.handicap
    if let url = user!.profileImageUrl{
      NetworkClient.getDataFromUrl(url: NSURL(string: url) as! URL, completion: { (data, response, error) in
        if error != nil{
          DispatchQueue.main.async{
            self.displayAlert("Error downloading profile image", title: "Error")
            return
          }
        }
        DispatchQueue.main.async {
          self.profileImage.image = UIImage(data:data!)?.circle
        }
      })
    }else{
      self.profileImage.image = UIImage(named:"golfDefault.png")?.circle
    }
    
    
  }
  
  func updateUserInfoInDatabase(){
    let userRef = self.ref.child("users").child(self.uid!)
    userRef.updateChildValues(self.valsToUpdate, withCompletionBlock: { (error, ref) in
      if error != nil{
        print(error)
        return
      }
      DispatchQueue.main.async{
        self.dismiss(animated: true, completion: nil)
        ModalTransitionMediator.instance.sendPopoverDismissed(modelChanged: true)
      }
      
    })
    
    
  }
  
}


//MARK: Text delegate

extension EditProfileController: UITextFieldDelegate{
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    if textField.tag == 10{
      if nameFieldButtonPressed{
        return true
      }else{
        return false
      }
    }else if textField.tag == 20{
      if emailFieldButtonPressed{
        return true
      }else{
        return false
      }
    }
    else{
      return true
    }
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    switch textField.tag{
    case 10:
      valsToUpdate["userName"] = textField.text
    case 20:
      valsToUpdate["email"] = textField.text
    case 30:
      valsToUpdate["handicap"] = textField.text
    case 40:
      valsToUpdate["zipCode"] = textField.text
    default:
      break
    }
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return false
  }
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    textField.text = ""
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
  {   let allowedCharacters = CharacterSet.decimalDigits
    let characterSet = CharacterSet(charactersIn: string)
    
    //Define text limits for handicap and zip code fields
    
    if textField.tag == 30 && !string.isEmpty  {
      let maxLength = 2
      let currentString: NSString = textField.text! as NSString
      let newString: NSString =
        currentString.replacingCharacters(in: range, with: string) as NSString
      if allowedCharacters.isSuperset(of: characterSet){
        return (newString.length <= maxLength) && (Int(newString as String)! <= 36)
      }
      else{
        return false
      }
    }else if textField.tag == 40 && !string.isEmpty{
      let maxLength = 5
      let currentString: NSString = textField.text! as NSString
      let newString: NSString =
        currentString.replacingCharacters(in: range, with: string) as NSString
      return newString.length <= maxLength && allowedCharacters.isSuperset(of: characterSet)
    }
    else{
      return true
    }
    
  }
  
  
}

//MARK: Keyboard notification

extension EditProfileController{
  func subscribeToKeyboardNotifications() {
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    
  }
  
  func unsubscribeFromKeyboardNotifications() {
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
  }
  
  
  func keyboardWillShow(notification: Notification) {
    if handicapField.isEditing{
      view.frame.origin.y -= getKeyboardHeight(notification: notification) - 150
    }else if zipField.isEditing{
      view.frame.origin.y -= getKeyboardHeight(notification: notification) - 150
    }
  }
  
  func keyboardWillHide(notification: Notification) {
    view.frame.origin.y = 0
  }
  
  func getKeyboardHeight(notification: Notification) -> CGFloat {
    let userInfo = notification.userInfo!
    let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
    return keyboardSize.cgRectValue.height
  }
}


//MARK: Image picker delegate

extension EditProfileController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
  
  func handleSelectProfileImage(){
    let picker = UIImagePickerController()
    picker.delegate = self
    picker.allowsEditing = true
    present(picker, animated: true, completion: nil)
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    //var selectedImage: UIImage?
    if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage{
      profileImage.image = image.resized(withPercentage: 0.1)
    }
    let imageName = NSUUID().uuidString
    let storageRef = FIRStorage.storage().reference().child("profileImage").child("\(imageName).png")
    if let uploadData = UIImagePNGRepresentation(profileImage.image!){
      storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
        if error != nil{
          print(error)
          return
        }
        
        if let imageUrl = metadata?.downloadURL()?.absoluteString{
          self.valsToUpdate["profileImage"] = imageUrl
        }
      })
    }
    
    
    dismiss(animated: true, completion: nil)
  }
}

//MARK: UIImage extension

extension UIImage {
  func resized(withPercentage percentage: CGFloat) -> UIImage? {
    let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
    UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
    defer { UIGraphicsEndImageContext() }
    draw(in: CGRect(origin: .zero, size: canvasSize))
    return UIGraphicsGetImageFromCurrentImageContext()
  }
  func resized(toWidth width: CGFloat) -> UIImage? {
    let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
    UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
    defer { UIGraphicsEndImageContext() }
    draw(in: CGRect(origin: .zero, size: canvasSize))
    return UIGraphicsGetImageFromCurrentImageContext()
  }
  
  var circle: UIImage {
    let square = size.width < size.height ? CGSize(width: size.width, height: size.width) : CGSize(width: size.height, height: size.height)
    let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: square))
    imageView.contentMode = UIViewContentMode.scaleAspectFill
    imageView.image = self
    imageView.layer.cornerRadius = square.width/2
    imageView.layer.masksToBounds = true
    UIGraphicsBeginImageContext(imageView.bounds.size)
    imageView.layer.render(in: UIGraphicsGetCurrentContext()!)
    let result = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return result!
  }
}

